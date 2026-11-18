---
description: Category vocabulary, the post writing and rendering workflow, and the markup for post-body components. Read before writing or editing a post.
paths: ["posts/**/*.qmd"]
---

# Writing a post

Rules 1 to 3 in the root `CLAUDE.md` still apply and are not repeated here: `_freeze/` stays
committed, one engine per post with Python naming a *kernel*, and a published slug is permanent.

## Categories

Vocabulary: `stats-cases`, `prior-sims`, `book-revisions`.

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

## Books posts: the transition format

**Every post in `book-revisions` takes one shape.** It is not a suggestion; it is the format of the
stream, and a book post that does not have it should be rewritten until it does:

1. **The licensed photograph first**, before the first heading, credit in the `figcaption`.
2. **`## Claim`** — what the book gets right, in the book's own terms.
3. **`## What it means in English`** — the same claim as prose a reader can act on. There is
   deliberately **no counter-claim section here**; the caveats came out of the format because they
   belong in the table's last row, where they are attached to the step that fails rather than to a
   heading.
4. **`## Code, maths, English`** — one `.transition` table, three columns, one row per step, running
   in the order the argument runs and ending where the claim is checked.
   - **Maths** is the book's own line, with its number (Lemma 5.2.5, Theorem 5.2.6(b)).
   - **Code** is the R that checks that step, and the printed value follows a `#`. A row with no
     printed value is a row that has not been checked; leave one out only when the step is exact by
     construction (`n <- 25`).
   - **English** is what the line says out loud, and the last row says what the derivation cannot
     deliver.
5. **A sources callout** at the end: edition, section and page for every line claimed from the book,
   the paper, and the photograph's licence.

And nothing else. No setup section, no "what this costs" list, no aside — those were the earlier
shape of this stream and they pushed the arithmetic and its meaning apart, which is the one thing the
table exists to prevent.

**The numbers must come from the run.** Compute them in a hidden `{r}` chunk and pull them into the
table with inline `` `r sprintf("%.3f", …)` ``. This post's first render printed a coverage column of
0.12 / 0.24 / 0.46 from a `length(m)`-instead-of-`n` slip; had those numbers been typed, they would
have shipped as evidence. The chunk is `include: false`, so the page shows no code cells and the
`engine` chip correctly stays silent — the code is the table.

## Tags

Every post declares `tags:` in frontmatter — the topics a reader would search for, not the stream:
`negative binomial`, `bootstrap`, `biased sampling`. `categories` stays the three-slug vocabulary above.

The tags are rendered into the metadata rule as outlined chips by `theme/post-tags.lua` (frontmatter
to a hidden div) and `theme/post-meta.html` (div to chips, beside `engine` and `output`). Author them
once, in frontmatter; there is no hand-written copy in the body to fall out of step.

## Post-body components

Layout devices an author opts into inside a post, defined in `theme/_post-components.scss`:

| Class | Markup |
|---|---|
| `.dual` | `::: {.dual}` wrapping alternating `::: {.spine}` / `::: {.dub}` cells |
| `.transition` | `::: {.transition}` wrapping one three-column table: Code / Maths / English — books posts only |
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
in the page. The deleted `posts/weakly-informative-priors/` post was the worked example: a
`density_curve()` helper histograms server-side and sends ~80 points per curve as a filled
`go.Scatter`, drawing the identical picture. Prefer that shape for any new distribution figure.

Nothing warns you. The failure mode is a page that renders correctly and loads slowly.
