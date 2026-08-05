# vpetkov.net

Hugo site for [vpetkov.net](https://vpetkov.net/), themed with a personal fork of PaperMod.

## Architecture

Three layers, each independently controlled:

1. **Content** — markdown under `content/` (this repo). Old WordPress posts live in
   `content/posts/old-wordpress-content/` and are tagged `old-wordpress-blog`
   (category `Old-WordPress-Blog`) as they get cleaned up.
2. **Theme** — `themes/PaperMod` is a git submodule pointing at
   [ventz/hugo-PaperMod](https://github.com/ventz/hugo-PaperMod), a fork of
   [adityatelange/hugo-PaperMod](https://github.com/adityatelange/hugo-PaperMod).
   The fork carries no local commits; it exists so upstream changes are pulled
   deliberately, never by surprise.
3. **Customizations** — the site-level `layouts/` and `assets/css/` override the
   theme's files of the same name (standard Hugo behavior). Every change is marked
   with a `Ventz Changes` comment. The theme submodule itself is never modified.

## Updating the theme

```sh
# 1. Update the fork from upstream (in a fork checkout):
git remote add upstream https://github.com/adityatelange/hugo-PaperMod.git  # once
git fetch upstream && git merge --ff-only upstream/master && git push origin master

# 2. Pull the fork into this site:
git submodule update --remote --merge themes/PaperMod

# 3. Re-check the overlay: diff each file in layouts/ and assets/css/ against the
#    theme's new version and re-apply the "Ventz Changes" blocks if upstream moved things.
```

Note: PaperMod migrated to Hugo's new template system (Hugo >= 0.146):
`layouts/_default/*` -> `layouts/*`, `partials/` -> `_partials/`,
`terms.html` -> `taxonomy.html`, typography split into `md-content.css`.
The overlay already follows the new structure.

## Local development

```sh
hugo server -D --disableFastRender
```

## Deploy — Cloudflare Pages

- Build command: `hugo --gc --minify`
- Output directory: `public`
- Environment variable: `HUGO_VERSION` set to a recent release (>= 0.146.0 required)
