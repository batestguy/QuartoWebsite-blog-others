---
description: SCSS architecture, the specificity traps that fail silently, category-accent plumbing, and the About page. Read before editing anything in theme/.
paths: ["theme/**"]
---

# Editing the theme

Everything here was found by rendering and measuring on Quarto 1.9.38, not by reading Quarto's
source. The recurring hazard is **specificity**: Quarto ships selectors that out-specify the obvious
override, so a wrong rule does nothing at all, or half-applies, rather than erroring.

## Theme architecture

`light.scss` and `dark.scss` contain **colour and nothing else**. Everything identical between them lives
in a shared partial, for the same reason the accent rules do — the two must not drift apart:

| File | Imported into | Holds |
|---|---|---|
| `_tokens.scss` | `scss:defaults` of both | font stacks, type scale, `$measure` |
| `_identity.scss` | `scss:rules` of both | every layout and type rule |
| `_post-components.scss` | `scss:rules` of both | opt-in post-body components, see below |
| `_category-accents.scss` | `scss:rules` of both | per-category colour plumbing |

`_identity.scss` never writes a colour literal. It consumes `--rule`, `--muted` and `--surface`, which
each theme defines for its own background. A hex in that file is a bug in one of the two themes by
definition.

The scheme is **sans for furniture, serif for the argument, mono for anything a machine produced** —
headings and navigation sans, body prose serif, dates and engines and code mono. Fonts are system stacks
with no webfont: a CDN link would put a network dependency on a site whose claim is that a saved page
still works, and would hand every reader to a third party for decoration.

> **Overriding Quarto's title block needs deliberate specificity.** Quarto ships
> `#title-block-header.quarto-title-block.default .quarto-title-meta` — that is (1,3,0). The obvious
> override `header#title-block-header .quarto-title-meta` is (1,1,1) and **loses on class count wherever
> you put it in the file**. Matching Quarto's own selector shape and adding the element gives (1,3,1),
> which wins without `!important`. Symptom of getting this wrong: the rule silently does nothing.

## How the per-category colours actually work

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

That fallback must stay expressed as `var(--category-accent, #{$body-color})` and never as a separate
`--category-accent: #{$body-color}` declaration. The original code did the latter and **silently disabled
every accent on the site**: `[data-category-name="prior-sims"]` and `.quarto-category` are both
specificity (0,1,0), the fallback block was declared second, so it won every tie and the accent never
applied. Markup, script and custom properties were all correct and categories still rendered plain black.
Fixed 2026-08-15.

## Post-body components

`theme/_post-components.scss` holds layout devices an author opts into inside a post. They are
separate from `_identity.scss` because that file is the identity every page wears, and these are
tools a single post reaches for. Same colour constraint as the other shared partials: `var(--rule)`,
`var(--muted)`, `var(--surface)` and the `--accent-*` customs only, **no hex literal**.

The markup an author types for each class is tabulated in `.claude/rules/posts.md` — keep the two in
step if a class is added or renamed.

Widening is the author's call at the point of use — `::: {.dual .column-body-outset}` — so no width
is baked into the component.

> **`.dual` pairs by SOURCE ORDER and has no per-row wrapper. Do not add one.** Children in the order
> `spine, dub, spine, dub` fill a two-column grid pairwise, so each pair lands on one row for free —
> and because the pairing is carried by order rather than markup, collapsing to one column on a phone
> leaves every `.dub` directly beneath the `.spine` it translates. Build it as two long columns, or
> wrap each row, and the mobile stack becomes *all the maths, then all the English*, which destroys
> the point of the device. This is invisible in the CSS, so it will look like untidiness worth
> fixing. It is not.

Two things about that grid are load-bearing and were found by measuring, not reading:

- Both the desktop and mobile tracks are `minmax(0, 1fr)`, never a bare `1fr`. A bare `1fr` takes its
  automatic minimum from `min-content`, so a cell holding a display formula pushes the track wider
  than the grid — measured at 390px, a 339px track with a 344px cell, overflowing the section by 5px.
- `.dual p { max-width: none }` is required. `main p` is capped at `$measure`, which is invisible at
  body width and bites the moment a `.dual` is widened.

Quarto's own callouts are restyled in the same file so a `.callout-note` and an `.aside-box` do not
sit on one page in two visual languages. That needs three specificity overrides, all of the kind
described for the title block above, and **all of which half-apply rather than fail cleanly** — the
panel takes the surface ground and the mono title while the edge stays Quarto's stock blue, because
Quarto never contested the half that worked. Quarto ships `div.callout-note.callout` (0,2,1) for the
edge colour, `div.callout` (0,1,1) for the border shorthand, and six
`div.callout-<type>.callout-style-default > .callout-header` rules (0,3,1) for the header tint.
Prefixing with `body` wins each on element count without `!important` and without naming all six
types.

## The engine chip

`theme/post-meta.html` adds *which language executed* and *frozen* to a post's metadata line, read from
the rendered DOM rather than from a second copy of `engine:` that would eventually disagree with the
first. Detection is deliberately strict — only `div.cell` (executed chunks) counts, only `python` and
`r` count, and if the result is not exactly one language it prints nothing.

The strictness is load-bearing. `posts/standard-error-plainly` is `engine: markdown` and still contains a
fenced code block; both executable posts contain incidental `powershell` blocks. A looser check labels
all three wrongly. On a site whose whole pitch is rigour, a wrong engine label is worse than none.

## The About page, and the two names

`about.qmd` uses Quarto's built-in `about` document type with **`template: trestles`** — image and
links in a left column, prose right. `jolla` was the alternative and was rejected because it
centre-aligns body text, which fights `main p { max-width: $measure }` and the left-aligned serif
measure the rest of the theme is built on.

**The site deliberately carries two names.** `about.qmd` is the only page that uses the legal name,
Jerry Bannister Zachary, because that is the page doing the credentialing. The footer,
`posts/_metadata.yml` and every post byline stay **"Batesthommie"** — one word, matching the handle
in `batesthommie@gmail.com`. It is not "Thommie Bates" and must not be split into two words; that
spelling was wrong and was corrected on 2026-08-15. This asymmetry between the two names looks like
an inconsistency somebody forgot to tidy — it is not. Do not "fix" it by unifying them.

## The Projects page

`projects.qmd` is **hand-written prose, not a listing** — the entries are external repositories, not
posts, so there is no category, no feed and no `listing:` block. It does not belong in
`CATEGORIES.md` and adding it there would be a category error in both senses.

Two standing rules for editing it:

- **Only link public repositories.** A link to a private repo 404s for every reader while still
  advertising that it exists. As of 2026-08-15 the page links **all eight** repositories on the
  account, so a new entry means a new repo — check its visibility before adding it.
  `messi-vs-ronaldo-r` was private until 2026-08-15 and was made public specifically to be listed.
- **Descriptions are written from each repo's README, not from memory.** Where a project is
  unfinished the page says so — `soccer-eurovsSA` is stage-one only. A projects page that overstates
  is worse than a short one on a site whose pitch is rigour.

Three specificity traps live in the About rules in `_identity.scss`, all of the kind described for the
title block above, and all of which fail *silently*:

- Quarto ships `div.quarto-about-trestles .about-entity .about-link` at (0,3,1). A plain
  `.about-links .about-link` is (0,2,0) and loses. The tell is that the monospace face applies while
  the border and padding do not — Quarto's rule sets no `font-family`, so it never contested that half.
- An about page has no author or date, but Quarto still emits an **empty** `.quarto-title-meta`, which
  the metadata-rule block would wrap in its two hairlines. It is hidden — but the rule hiding it must
  out-specify that block's own (1,3,1), so it carries the full `header#title-block-header…` prefix.
- `:empty` cannot be used for that: the div contains whitespace, which counts as a text node.

Verified against Quarto 1.9.38: the trestles body column is wrapped in `<main class="content">`, so
`main p` already gives the bio the serif face and `$measure` with no extra rule. The contact block
overrides back to mono, and needs `max-width: none` to escape `$measure`.

`code-tools: false` is set in the About frontmatter. The site-wide `code-tools: true` otherwise renders
a "Code" button beside the name in the entity column, revealing a page with no code on it.

**The avatar carries the only `!important` in `_identity.scss`, and the reason is not obvious.**
(It is not the only one in the theme — `_category-accents.scss` has one on the category chip's
`color`. Both files used to claim the avatar's was the theme's only one; that was wrong.)
`image-width: 200px` in the About frontmatter becomes an inline `style="height: 200px; width: 200px"`
on the `img`, which no selector can beat. The mobile rule in `_identity.scss` shrinks it to 130px
below the 991.98px breakpoint — where the stock trestles header otherwise costs a phone reader a full
screen of furniture before the first line of prose — and `!important` is the only thing that can do it.

The trap is that **deleting `image-width` does not remove the inline style.** Reading
`_image.ejs.html` suggests it does: with the key absent, `imageSize()` returns `""`. But Quarto
defaults the option upstream in `quarto.js` *before* the template runs — trestles gets `20em`, jolla
and solana `15em`. So removing the key only changes 200px to ~320px and leaves the override just as
blocked. Verified by rendering on 1.9.38, not by reading. Keep the key, and keep the `!important`
confined to the two declarations that contest the inline style.

`image-alt` is set in the same block: it is the only way to get an `alt` on that image, and Quarto
emits none by default.
