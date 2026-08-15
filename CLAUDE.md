# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working in this repository.

## What this is

A Quarto **website** (not a bare blog) at `C:\Users\TOSHIBA\quarto-blog`, published to GitHub Pages.
Three content streams, flat `posts/` directory, categories drive all filtering. Posts are written in
**either R or Python**, one engine per post.

```
_quarto.yml            site config — theme, navbar, freeze
index.qmd              landing page (hand-written, not a listing)
blog.qmd               every post + category filter sidebar
stats.qmd              hub → posts categorised stats-cases
simulations.qmd        hub → posts categorised prior-sims
books.qmd              hub → posts categorised book-revisions
about.qmd
CATEGORIES.md          controlled vocabulary — READ BEFORE ADDING A CATEGORY
.gitattributes         LF normalisation — load-bearing for _freeze, see rule 1
theme/
  light.scss           cosmo base + accent vars
  dark.scss            darkly base + accent vars
  _category-accents.scss   shared accent rules, imported by both
  category-accents.html    decodes Quarto's base64 category slugs, see below
posts/
  _metadata.yml        defaults applied to every post
  _template/index.qmd  copy-to-start skeleton
  <slug>/index.qmd     one folder per post, assets alongside
_freeze/               COMMITTED execution cache — see below
```

Anything starting with `_` is ignored by Quarto's renderer, which is why `_template/` never publishes.

## The three rules that matter

Everything else in this file is detail. These three are the ones that cause silent, hard-to-diagnose
damage when broken.

### 1. `_freeze/` is committed. Never gitignore it.

`execute: freeze: auto` is set project-wide in `_quarto.yml`. Once a post is rendered and its freeze
artifacts are committed, Quarto **replays stored results instead of re-executing** until the `.qmd`
source itself changes. That gives three things:

- A full `quarto render` stays fast no matter how many simulation-heavy posts accumulate.
- Upgrading `ds-general` or an R package cannot retroactively alter a published post's numbers.
- The site rebuilds on a machine that lacks the original packages entirely.

**All three guarantees are void if `_freeze/` is not in git.** `.gitignore` has a comment saying so.
If you ever see `_freeze` proposed for ignoring, that is a bug.

To deliberately re-execute a post: `quarto render posts/<slug>/index.qmd --no-freeze`.

`.gitattributes` (`* text=auto`) is part of this rule, not housekeeping. Freeze artifacts committed from
Windows without it churn on every commit and diff as *wholly rewritten* — the cache whose job is to prove
a post did not change would look like it changed on every touch. The side effect is that git prints
`LF will be replaced by CRLF` on nearly every `git diff`/`git add` here. That warning is expected; it is
not a sign anything is wrong.

### 2. One engine per post, and Python posts name a *kernel*, not an interpreter

Declared in frontmatter. Do not mix R and Python chunks in one document — `reticulate` is installed and
would work, but it doubles the failure surface per post for no benefit here.

| Post type | Frontmatter | Chunks |
|---|---|---|
| R | `engine: knitr` | ` ```{r} ` |
| Python | `engine: jupyter` + `jupyter: ds-general` | ` ```{python} ` |
| Prose only | `engine: markdown` | none |

The `jupyter: ds-general` line names a **registered kernelspec**. That kernelspec carries an `env` block
(`PATH` including `<env>\Library\bin`, plus `CONDA_PREFIX`) which makes it behave as *activated*.

> **Pointing Quarto at a bare `python.exe` instead reproduces `ENVIRONMENTS.md` TRAP #3**: numpy fails to
> link `libblas.dll` and dies with native crash `0xc06d007f`, exit 127, **no traceback**. A Python post
> that fails with no error message is almost always this.

> **Never re-run `ipykernel install` for these envs.** It wipes the `env` block and silently breaks the
> kernel. If a Python post starts crashing with no traceback, check this first.

### 3. Slugs are permanent; categories are free

The folder name under `posts/` **is** the public URL. Renaming `posts/logistic-separation/` breaks every
inbound link, bookmark, and RSS GUID. Treat a published slug as immutable — if the title turns out wrong,
change `title:` and leave the folder alone.

Re-categorising costs nothing: it is one line of frontmatter and no URL changes. That asymmetry is the
whole reason `posts/` is flat instead of nested by category.

Post folders are **not** date-prefixed. The `date:` field drives sort order, so a post can be re-dated
without changing its URL.

## Categories

Launch vocabulary: `stats-cases`, `prior-sims`, `book-revisions`.

**Quarto does not validate categories.** A typo silently creates a new one — `prior-sim` instead of
`prior-sims` produces a post that vanishes from the Simulations hub and lands in a one-item category
nobody will find. No error, no warning.

So `CATEGORIES.md` is the controlled vocabulary. Read it before writing a `categories:` block, and add
new slugs there *first*, deliberately. It also documents the four-step process for adding a stream
(hub page + navbar line + accent colour in both themes + accent include).

### How the per-category colours actually work

Verified against Quarto 1.9.38's real output — a category slug reaches the DOM in three different shapes,
two of them **base64-encoded**:

| Surface | Markup | Slug |
|---|---|---|
| listing chip | `onclick="…quartoListingCategory('c3RhdHMtY2FzZXM=')"` | base64 |
| sidebar filter | `data-category="c3RhdHMtY2FzZXM="` | base64 |
| post header | `<div class="quarto-category">stats-cases</div>` | plain text, no attribute |

`theme/category-accents.html` (injected site-wide via `include-after-body`) decodes all three onto a
single `data-category-name` attribute, so `theme/_category-accents.scss` selects on readable slugs
identical to the ones in `CATEGORIES.md`. Base64 literals in a stylesheet would be unreadable and would
stop matching *silently* if Quarto changed its encoding.

If that script does not run, categories render in the plain body colour — nothing breaks and no category
is shown the wrong colour. Same for a typo'd slug: it gets no accent rather than inheriting a
neighbour's, which is what makes the typo visible.

## Listings, feeds, and page weight

Every listing page (`blog.qmd` and the three hubs) declares `feed: type: partial`, never `feed: true`.

A **full** feed embeds each post's entire rendered body in the XML — interactive-figure JSON included.
On a simulation-heavy blog that is not a rounding error: it produced a **7.2 MB `blog.xml`**. Partial
feeds emit `description:` only, and the current `_site/blog.xml` is ~2.9 KB. If a feed file is suddenly
megabytes, someone has written `feed: true`.

The same budget applies inside a post. **Bin or summarise before handing data to plotly.** `go.Histogram`
and `go.Violin` ship every raw value to the browser and compute client-side — 60,000 draws × 3 priors ×
2 figures is ~7 MB of JSON embedded in the page. `posts/weakly-informative-priors/index.qmd` is the
worked example: a `density_curve()` helper histograms server-side and sends ~80 points per curve as a
filled `go.Scatter`, drawing the identical picture. Prefer that shape for any new distribution figure.

Nothing warns you about either. The failure mode is a page that renders correctly and loads slowly.

## Working on a post

```powershell
Copy-Item -Recurse posts\_template posts\<slug>     # start
quarto render posts/<slug>/index.qmd                # inner loop — ONE post
quarto preview                                      # whole site, live reload
quarto render                                       # full build (frozen posts skip execution)
```

Rendering a single file is the normal inner loop. Reach for a full `quarto render` before publishing,
not while writing.

`draft: true` keeps a post out of every listing, the RSS feed, search, and the sitemap. Verified on
Quarto 1.9.38: the default `draft-mode` also emits the page itself as an **empty HTML document** — 90
bytes, no content — in `quarto render` *and* in `quarto preview`. Draft prose and results never leave the
machine, which is the safe default for a public repo.

The practical consequence: **you cannot read a draft in the browser while `draft: true` is set.** So the
normal writing workflow is to leave the flag off and simply not publish; `draft: true` is for parking a
post that must stay unpublishable while it sits in the repo. To read a parked draft, comment the flag out
temporarily. (Setting `draft-mode: unlinked` in `_quarto.yml` would make drafts viewable at their direct
URL — but it also deploys them to the public site, unlinked. Not done, deliberately.)

`posts/bootstrap-small-samples/` is a live draft and exists partly as a standing check that this holds.

Post frontmatter should stay minimal — `title`, `description`, `date`, `categories`, `engine`. Everything
else (author, toc, code folding, figure sizes, reading time) comes from `posts/_metadata.yml`, so a
site-wide reading change is one edit there rather than N edits across posts.

`description:` is not optional. It is what appears on hub listings and in RSS, and for most readers it is
the only thing they will read. Make it the claim, not a teaser.

## Publishing

```powershell
quarto publish gh-pages
```

Renders **locally** and pushes the built site to the `gh-pages` branch. Live at
<https://batestguy.github.io/QuartoWebsite-blog-others/>.

**`quarto publish` rewrites `.gitignore`.** It re-appends `/.quarto/` and `**/*.quarto_ipynb` whenever
they are absent, which is why those two lines sit there duplicating rules already covered by `.quarto/`
and `**/*.quarto_ipynb*` higher up. Deleting them does not clean anything — they return on the next
publish. Leave them. Note the starred pattern is the one that actually works: an interrupted render
leaves `index.quarto_ipynb_1`, `_2`, … which Quarto's own unstarred pattern misses.

**Deliberately not GitHub Actions.** CI would have to reconstruct the R and Python environments on every
push, and with 1065 unpinned R packages that is a build that works until the day it doesn't. Local render
plus committed `_freeze` sidesteps it. Revisit only after `renv` lands.

## Toolchain

Quarto **1.9.38** on `PATH`. It bundles Pandoc, Typst, Deno, and Dart Sass — do not install those
separately.

**R 4.5.2** — invoke as **`Rscript`**. Bare `R` is a PowerShell alias for `Invoke-History` and will not
start R. Used here: `ggiraph`, `plotly`, `ggplot2`, `knitr`, `downlit`. There is **no `IRkernel`**, so R
cannot go through Jupyter — R chunks run via Quarto's knitr engine only.

**Python** — the workhorse env is `ds-general` (3.12, `C:\Users\TOSHIBA\ds-general\`), reached in posts by
kernel name (see rule 2). Bare `python` is `C:\Python314\python.exe` and is the *wrong* interpreter for
this project. For one-off scripts outside Quarto:

```powershell
& C:\Users\TOSHIBA\ds-general\python.exe script.py
```

`conda activate` is a no-op on this box — use full paths or `conda run -n <env> python …`.

Interactivity is **client-side only** — plotly, ggiraph, Vega-Lite. There is no Shiny or Dash server, by
decision. Anything requiring a backend does not belong here.

See `ENVIRONMENTS.md` for the full machine map; read its TRAPS section before running anything unfamiliar.

> `ENVIRONMENTS.md` and `New Text Document.txt` are **local-only and gitignored on purpose** — this repo
> is public, and the machine map is a reconnaissance document to anyone who is not working on this box.
> They exist on disk next to this file. Do not `git add -f` them.

`_quarto.yml` pins `render: ["**/*.qmd"]` for the same reason. Quarto renders every `.md` in a project by
default, so without that line `CLAUDE.md`, `CATEGORIES.md` and `ENVIRONMENTS.md` would all be built into
`_site/` and published as public pages — gitignoring a file keeps it out of the *repo*, not out of the
*rendered site*. Do not widen that glob.

## Where this lives, and why it moved

**The project lives at `C:\Users\TOSHIBA\quarto-blog` (SSD, NTFS).** It was scaffolded on
`D:\QuartoWebsite-blog-others` and moved on 2026-08-12 after measurement, not preference:

| | write 500 small files | delete them |
|---|---|---|
| `C:` Samsung SSD, NTFS | **770 files/sec** | 0.2 s |
| `D:` USB stick, FAT32 | **5 files/sec** | 15.8 s |

A full `quarto render` writes 400+ `site_libs` files plus the whole `_site` tree. At 5 files/sec that is
a multi-minute build dominated entirely by I/O; on `C:` the same cold build is ~90 s and an incremental
`quarto preview` reload is seconds. None of that gap is R or Python — execution is frozen either way.

Consequences of NTFS: symlinks work, no 4 GB file cap, and **`safe.directory` is no longer needed** —
that workaround was a FAT32/removable-drive artifact (`ENVIRONMENTS.md` TRAP #1).

A stale copy may still exist at `D:\QuartoWebsite-blog-others`. It is **not** the working tree — do not
edit it, and do not treat it as the backup. The GitHub remote is the backup; push often.

Still true regardless of drive: **never create a venv or conda env inside the project folder.** A venv at
`D:\ds-ml-env` was lost exactly that way. Reference the existing envs by absolute path.

## Deferred, with a trigger

`renv::init()` and a `requirements.txt` for `ds-general` are **not** done yet. `_freeze` protects
*already-published* posts; it does nothing for a post being actively written when a package changes
underneath it.

Pin when either: (a) a `--no-freeze` re-render produces different numbers than the frozen output, or
(b) the site moves to CI. Note `targets`, `arrow`, `duckdb`, and `RSQLite` are **not** installed for R;
DuckDB and Polars are Python-only on this machine.
