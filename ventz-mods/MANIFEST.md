# MANIFEST — ventz-mods snapshot

**Generated:** 2026-08-06 by `generate-ventz-mods.sh` (do not edit by hand)

## Base this overlay was built against

| | |
|---|---|
| PaperMod commit | `d3768854d00ad003b0a8dbdba254ce9224377a01` (`d376885`, 2026-08-02) |
| PaperMod remote | https://github.com/ventz/hugo-PaperMod.git |
| Theme min Hugo  | 0.146.0 |
| Hugo used       | v0.164.0+extended+withdeploy |

The patches in `patches/` are diffs **from that exact theme commit**. Re-apply
them after an upstream merge with `./ventz-mods/reapply.sh` (see README).

## Theme overrides (18) — modified copies of theme files

These conflict with upstream changes. Each has a patch in `patches/`.

- `layouts/_markup/render-image.html` — +12/-0
- `layouts/_partials/comments.html` — +67/-0
- `layouts/_partials/extend_footer.html` — +13/-3
- `layouts/_partials/footer.html` — +16/-2
- `layouts/_partials/header.html` — +9/-2
- `layouts/_partials/templates/opengraph.html` — +3/-1
- `layouts/baseof.html` — +7/-5
- `layouts/index.json` — +4/-1
- `layouts/list.html` — +24/-8
- `layouts/rss.xml` — +3/-1
- `layouts/taxonomy.html` — +85/-0
- `assets/css/common/header.css` — +3/-0
- `assets/css/common/md-content.css` — +24/-0
- `assets/css/common/post-entry.css` — +112/-3
- `assets/css/common/post-single.css` — +44/-1
- `assets/css/core/reset.css` — +22/-1
- `assets/css/core/theme-vars.css` — +21/-4
- `assets/js/fastsearch.js` — +128/-2

## Site-only files (18) — no theme counterpart

These never conflict; copy them in as-is.

- `layouts/about.html`
- `layouts/pages.html`
- `assets/css/extended/ventz-a11y.css`
- `assets/css/extended/ventz-entry-preview.css`
- `assets/css/extended/ventz-search.css`
- `static/_headers`
- `static/android-chrome-192x192.png`
- `static/android-chrome-512x512.png`
- `static/apple-touch-icon.png`
- `static/bsd_logo.png`
- `static/favicon-16x16.png`
- `static/favicon-32x32.png`
- `static/favicon.ico`
- `static/js/wordcloud2.js`
- `static/site.webmanifest`
- `archetypes/default.md`
- `archetypes/posts.md`
- `hugo.yaml`

