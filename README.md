# vpetkov.net

Hugo site for [vpetkov.net](https://vpetkov.net/), themed with a personal fork of PaperMod.

## Architecture

Three layers, each independently controlled:

1. **Content** — markdown under `content/` (this repo). The 44 migrated WordPress
   posts live in `content/posts/old-wordpress-content/`, tagged `old-wordpress-blog`
   (category `Old-WordPress-Blog`).
2. **Theme** — `themes/PaperMod` is a git submodule pointing at
   [ventz/hugo-PaperMod](https://github.com/ventz/hugo-PaperMod), a fork of
   [adityatelange/hugo-PaperMod](https://github.com/adityatelange/hugo-PaperMod).
   The fork carries no local commits; it exists so upstream changes are pulled
   deliberately, never by surprise.
3. **Customizations** — the site-level `layouts/` and `assets/css/` override the
   theme's files of the same name (standard Hugo behavior). Every change is marked
   with a `Ventz Changes` comment. The theme submodule itself is never modified.
   (`ventz-mods/` is a portable backup snapshot of the overlay, regenerated via
   `./generate-ventz-mods.sh` — Hugo never reads it; see its README.)

## Updating the theme

```sh
# 1. Update the fork from upstream (in a fork checkout):
git remote add upstream https://github.com/adityatelange/hugo-PaperMod.git  # once
git fetch upstream && git merge --ff-only upstream/master && git push origin master

# 2. Pull the fork into this site:
git submodule update --remote --merge themes/PaperMod

# 3. Re-check the overlay: diff each file in layouts/ and assets/css/ against the
#    theme's new version and re-apply the "Ventz Changes" blocks if upstream moved things.
#    Start with layouts/_partials/header.html — it is a whole-file copy of the theme
#    partial (only the logo aria-label removed) and goes stale first on theme updates.
#    layouts/rss.xml and layouts/_partials/templates/opengraph.html are whole-file
#    copies too (each differs from the theme by one Language.Locale line).
```

Note: PaperMod migrated to Hugo's new template system (Hugo >= 0.146):
`layouts/_default/*` -> `layouts/*`, `partials/` -> `_partials/`,
`terms.html` -> `taxonomy.html`, typography split into `md-content.css`.
The overlay already follows the new structure.

## Local development

```sh
hugo server -D --disableFastRender
```

## Comments (giscus)

Comments are GitHub Discussions on [ventz/vpetkov.net-comments](https://github.com/ventz/vpetkov.net-comments),
rendered by [giscus](https://giscus.app/). The embed is our overlay partial
`layouts/_partials/comments.html` (theme-synced to PaperMod's light/dark toggle);
all settings live in `hugo.yaml` under `params.giscus`.

Setting up a comments repo from scratch:

1. Create a **public** GitHub repo (private repos don't work with giscus):
   `gh repo create ventz/<name> --public --add-readme`
2. Enable Discussions on it:
   `gh api -X PATCH repos/ventz/<name> -f has_discussions=true`
3. Install the giscus GitHub App on that repo (manual, browser):
   <https://github.com/apps/giscus> → Configure → select the repo.
4. Get the IDs for `hugo.yaml`:
   - `repoID`: `gh api repos/ventz/<name> --jq .node_id`
   - `categoryID`: `gh api graphql -f query='query { repository(owner:"ventz", name:"<name>") { discussionCategories(first:10) { nodes { id name } } } }'`
     (use the **General** category — or create an "Announcements-type" category so
     only giscus can open threads)
   - Alternatively paste the repo into <https://giscus.app/> and copy the generated values.
5. Update `params.giscus` in `hugo.yaml`: `repo`, `repoID`, `category`, `categoryID`.
   `mapping: url` ties each thread to the page URL — don't change it after
   comments exist or existing threads orphan.

## Deploy — Cloudflare Pages

- Build command: `hugo --gc --minify`
- Output directory: `public`
- Environment variable: `HUGO_VERSION` set to a recent release (>= 0.146.0 required)
