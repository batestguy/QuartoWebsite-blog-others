---
description: Category vocabulary, the post writing and rendering workflow, and the markup for post-body components. Read before writing or editing a post.
paths: ["posts/**/*.qmd"]
---

# Writing a post

Rules 1 to 3 in the root `CLAUDE.md` still apply and are not repeated here: `_freeze/` stays
committed, one engine per post with Python naming a *kernel*, and a published slug is permanent.

## Categories

Vocabulary: `stats-cases`, `prior-sims`, `book-revisions`, `stats-in-life`.

**Quarto does not validate categories.** A typo silently creates a new one — `prior-sim` instead of
`prior-sims` produces a post that vanishes from the Simulations hub and lands in a one-item category
nobody will find. No error, no warning.

So `CATEGORIES.md` is the controlled vocabulary. Read it before writing a `categories:` block, and add
new slugs there *first*, deliberately. It also documents the four-step process for adding a stream
(hub page + navbar line + accent colour in both themes + accent include).

The per-category colour plumbing is theme work, and lives in `.claude/rules/theme.md`.

## Workflow

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

## Post-body components

Layout devices an author opts into inside a post, defined in `theme/_post-components.scss`:

| Class | Markup |
|---|---|
| `.dual` | `::: {.dual}` wrapping alternating `::: {.spine}` / `::: {.dub}` cells |
| `.aside-box .not-crazy` | `::: {.aside-box .not-crazy}` — label drawn in CSS |
| `.aside-box .hommie` | `::: {.aside-box .hommie}` — `> blockquote` is the naive voice, the `p` after it the answer |
| `.arena` | `::: {.arena}` wrapping a figure cell then `::: {.interpreter}` |
| `.state-calm` / `.state-tipping` / `.state-inevitable` | inside `.interpreter`, escalating by weight |

Widening is the author's call at the point of use — `::: {.dual .column-body-outset}` — so no width
is baked into the component.

**`.dual` children go in source order `spine, dub, spine, dub`** with no per-row wrapper. That is what
makes each `.dub` land directly beneath the `.spine` it translates when the grid collapses on a phone.
Grouping rows in wrappers, or writing two long columns, breaks the mobile stack.

**Use the components as built.** If one needs a CSS change, stop and flag it rather than editing
`theme/` mid-post.

## Page weight inside a post

**Bin or summarise before handing data to plotly.** `go.Histogram` and `go.Violin` ship every raw value
to the browser and compute client-side — 60,000 draws × 3 priors × 2 figures is ~7 MB of JSON embedded
in the page. `posts/weakly-informative-priors/index.qmd` is the worked example: a `density_curve()`
helper histograms server-side and sends ~80 points per curve as a filled `go.Scatter`, drawing the
identical picture. Prefer that shape for any new distribution figure.

Nothing warns you. The failure mode is a page that renders correctly and loads slowly.
