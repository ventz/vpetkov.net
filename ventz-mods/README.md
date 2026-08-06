# ventz-mods — customization backup snapshot

Everything this site changes on top of a stock PaperMod install, captured by
`../generate-ventz-mods.sh`. Regenerate after any overlay change:

```sh
./generate-ventz-mods.sh
```

**This directory is NOT read by Hugo.** The live overlay is `layouts/`,
`assets/`, `static/`, `archetypes/` and `hugo.yaml` at the repo root. This is a
portable backup + re-apply kit.

## What's in here

| Path | What |
|---|---|
| `MANIFEST.md` | **Provenance** — the exact PaperMod commit and Hugo version this overlay was built against, plus the full file inventory. Generated; don't edit. |
| `base/` | The **pristine theme version** of each override — the merge base. Storing it makes the snapshot self-contained (re-apply needs no submodule history). |
| `patches/` | One unified diff per *theme override*, for human review and sharing ("what exactly did Ventz change in this file?"). |
| `reapply.sh` | Generated helper that replays the whole overlay onto an updated theme. |
| `layouts/` `assets/` `static/` `archetypes/` `hugo.yaml` | Verbatim copies of the live files. |

Files identical to the theme are skipped — if it's in here, it's a real
customization.

## Two kinds of file

- **Theme overrides** — modified copies of files that also exist in
  `themes/PaperMod`. These are the ones upstream can break, so each gets a
  stored merge base and a `.patch`. Every changed hunk carries a
  `Ventz Changes` marker (see below).
- **Site-only** — files with no theme counterpart (`assets/css/extended/*`,
  `static/*`, `layouts/about.html`, `layouts/pages.html`, `hugo.yaml`, …).
  These never conflict; they're copied in as-is.

## Marker convention

Every hunk that differs from the theme is annotated so its intent survives a
merge conflict months later:

```css
/* Ventz Changes: <one-line why> */          /* single-property change */

/* Ventz Changes BEGIN: <why> */             /* multi-line block */
...
/* Ventz Changes END */
```

`(a11y)` tags changes made for the WCAG 2.2 AA audit. In templates the same
markers go in Hugo comments: `{{- /* Ventz Changes: ... */}}`.

`generate-ventz-mods.sh` **enforces this** — it scans every generated patch and
warns about any hunk with added lines but no marker, and lists offenders in
`MANIFEST.md`. A clean run prints `all N override files fully marked`.

## Re-applying after a PaperMod upgrade

```sh
cd themes/PaperMod
git fetch upstream && git merge --ff-only upstream/master && git push
cd ../..
git add themes/PaperMod

./ventz-mods/reapply.sh          # copies site-only files, 3-way merges theme overrides
```

Each override is resolved by a real 3-way merge (`git merge-file`, since BSD
`patch` on macOS has no `--merge`):

| | |
|---|---|
| base | `ventz-mods/base/<f>` — the theme file the overlay was built on |
| ours | `ventz-mods/<f>` — the customized version |
| theirs | `themes/PaperMod/<f>` — the new upstream version |

Outcomes:

- `ok` — upstream didn't touch this file; overlay restored as-is.
- `merged` — upstream changed other parts of the file; those folded in
  automatically and the Ventz hunks survived.
- `CONFLICT` — upstream changed the *same lines*. The file has `<<<<<<<`
  markers labelled `Ventz overlay` / `PaperMod (new)`. Because every hunk is
  marked, the conflict shows *why* the line was changed, e.g.:

  ```
  <<<<<<< Ventz overlay
      /* Ventz Changes: Made Pager Wider: 720px; */
      --main-width: 820px;
  =======
      --main-width: 760px;
  >>>>>>> PaperMod (new)
  ```

- `GONE` — the theme deleted that file. The snapshot copy is dropped in
  verbatim and flagged; decide whether the customization is still needed.
- `SKIPPED` — a *site-only* file on disk differs from the snapshot (e.g.
  `hugo.yaml` edited since the last `generate-ventz-mods.sh`). Nothing is
  overwritten. Re-snapshot first, or re-run with `FORCE=1` to take the
  snapshot version.

Then verify and re-snapshot:

```sh
hugo server -D --disableFastRender
./generate-ventz-mods.sh         # refreshes patches against the NEW theme commit
```

That last step is what keeps the patches usable — they are always diffs against
the commit recorded in `MANIFEST.md`, not against some older base.

## Hugo upgrades

`MANIFEST.md` records the Hugo version and the theme's `min_version`. PaperMod's
0.146+ restructure (`layouts/_default/*` → `layouts/*`, `partials/` →
`_partials/`, `terms.html` → `taxonomy.html`) is already reflected here — an
overlay at an old path silently stops overriding rather than erroring, so after
a Hugo/theme major bump, confirm `generate-ventz-mods.sh` still classifies your
files as `override` and not `site-only`. A file that flips to `site-only` means
its theme counterpart moved and your override is now dead code.

The pre-0.146 snapshot is preserved in git history (commit `be88440`).

## Fresh install from scratch

```sh
git clone --recurse-submodules <site-repo> && cd <site>
./ventz-mods/reapply.sh
```
