// vpetkov-analytics-archiver
// Daily cron: archives per-path page hits from Cloudflare's GraphQL analytics
// (8-day retention) into the private vpetkov-analytics R2 bucket (forever).
// Self-healing: each run backfills any missing day still inside the window.
// Manual trigger: GET with "Authorization: Bearer <ANALYTICS_TOKEN>".

export default {
    async scheduled(event, env, ctx) {
        ctx.waitUntil(archive(env));
    },
    async fetch(req, env) {
        const auth = req.headers.get("Authorization") || "";
        // missing-binding guard: never let "Bearer undefined" authenticate
        if (!env.ANALYTICS_TOKEN || auth !== `Bearer ${env.ANALYTICS_TOKEN}`) {
            return new Response("forbidden", { status: 403 });
        }
        try {
            return Response.json(await archive(env));
        } catch (e) {
            return new Response(`error: ${e.message}`, { status: 500 });
        }
    },
};

async function archive(env) {
    const wrote = [], skipped = [];
    // days 1..7 ago (never today — the day must be complete)
    for (let i = 1; i <= 7; i++) {
        const day = new Date(Date.now() - i * 86400e3).toISOString().slice(0, 10);
        const key = `daily/${day}.json`;
        if (await env.BUCKET.head(key)) {
            skipped.push(day);
            continue;
        }
        const data = await fetchDay(env, day);
        await env.BUCKET.put(key, JSON.stringify(data), {
            httpMetadata: { contentType: "application/json" },
        });
        wrote.push(day);
    }
    return { wrote, skipped };
}

async function fetchDay(env, day) {
    const start = `${day}T00:00:00Z`;
    const end = new Date(Date.parse(start) + 86400e3).toISOString().slice(0, 19) + "Z";
    const window = `datetime_geq: "${start}", datetime_lt: "${end}", clientRequestHTTPHost: "${env.HOST}"`;
    const query = `{ viewer { zones(filter: {zoneTag: "${env.ZONE_ID}"}) {
        paths: httpRequestsAdaptiveGroups(limit: 500, filter: {${window}, edgeResponseStatus: 200}, orderBy: [count_DESC]) {
            count dimensions { clientRequestPath } }
        codes: httpRequestsAdaptiveGroups(limit: 25, filter: {${window}}, orderBy: [count_DESC]) {
            count dimensions { edgeResponseStatus } }
    } } }`;

    const r = await fetch("https://api.cloudflare.com/client/v4/graphql", {
        method: "POST",
        headers: {
            Authorization: `Bearer ${env.ANALYTICS_TOKEN}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ query }),
    });
    const d = await r.json();
    if (d.errors) throw new Error(d.errors[0].message);
    const z = d.data.viewer.zones[0];
    return {
        date: day,
        paths: Object.fromEntries(z.paths.map((g) => [g.dimensions.clientRequestPath, g.count])),
        status: Object.fromEntries(z.codes.map((g) => [String(g.dimensions.edgeResponseStatus), g.count])),
    };
}
