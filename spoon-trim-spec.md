# Spec — Cutting the spoon post to six sections

**Short name:** `spoon-trim`
**Status:** specification only. No post file rewritten, no render run, no publish.
**Date:** 2026-11-16
**Source request:** `New general rules.txt` — "TASK: Reformat the spoon post. Keep 6 fixed sections. Cut
words to bones. Output a Quarto .qmd." Plus the interview overrides recorded in §10.

---

## 0. One-line answer

The post keeps its URL, its R chunks and its existing palette. The source file is **4,266 words**
counting YAML and code; the prose is cut to **250**. Six sections remain: three carry one number each,
the fourth states the frame, the fifth holds **four plotly charts computed by the existing simulation**,
the sixth is the pidgin aside. Prose target **200 words**, ceiling **300**, with El-Rufai's verbatim
quotes and the photo credit outside that count.
The charts move out of the argument and into the simulation, where they are actually computed, and the
**Maths / English section is dropped** on instruction.

---

## 1. Baseline, and the step before any editing

`posts/how-big-should-the-spoon-be/` **does not exist in the local working tree**. Local `main` is
2 ahead / 13 behind `origin/main`; the post and its freeze artifact are upstream only
(`f8ba8ac Section the spoon post, then score El-Rufai on each claim`).

Interview answer: reset local `main` to `origin/main` and work from there. That discards two local
commits — `8a49b77` (hierarchical education gender gap) and `8c7af17` (landing page cut) — so preserve
them first rather than relying on reflog archaeology:

```bash
git fetch --all --prune
git branch backup-local-pre-spoon main        # keep the two local commits reachable
git reset --hard origin/main
```

`backup-local-pre-spoon` is never merged in this task; it exists so the two commits are not left to
`git reflog expire`.

**Do not touch** `_freeze/` by hand. The rewrite needs one deliberate re-execution:

```bash
quarto render posts/how-big-should-the-spoon-be/index.qmd --no-freeze
```

Untracked and staying untracked: `New general rules.txt`, `ENVIRONMENTS.md`,
`New Text Document.txt`, `Screenshot 2026-08-15 064916.png`. This spec file is a `.md` at the repo
root, and `_quarto.yml` renders only `**/*.qmd`, so it will not be built into `_site/`.

---

## 2. The six sections

Literal headings, in this order, `##` level. No sub-headings except the four inside section 5.

| # | Heading | Asset (exactly one) | Prose cap | Charts |
|---|---|---|---|---|
| 1 | Question | STAT `(proof)` — ±2.18 pp at 2,000 interviews | 28 | none |
| 2 | Claim | QUOTE — El-Rufai, verbatim, + portrait (§3) | 22 | none |
| 3 | Counter-claim | STAT `(sim)` — 3,967 + 0 out of 4,000 each | 32 | none |
| 4 | Setup | STAT `(assume)` — 31% phone reach, 90m register | 30 | none |
| 5 | The simulation | four charts, one stat per block | 50 + caps | 4 |
| 6 | Hommie's take | QUOTE `— hommie` (existing pidgin line) | 25 | none |

`## Hommie's take` is rendered with the existing component, `::: {.aside-box .hommie}`, whose `::before`
already prints the label "Hommie's take" (`theme/_post-components.scss:178`). Do **not** also write the
heading — pick the component, drop the `##`. If the component is used, section 6's word count is the
aside's own text only.

Section 5's four blocks, each `###`, each following the law's order — number, chart, folded method:

| Block | Heading | Chart | Stat |
|---|---|---|---|
| 5.1 | The country | C1 frame vs country bars | Green +3.5 in the frame, Blue +8 in the country `(sim)` |
| 5.2 | The spoon, priced | C2 SE vs n | 0.0011% `(proof)` |
| 5.3 | Four thousand runs | C3 the ladder | 99.2% at 500; 0.0% at 40,000 `(sim)` |
| 5.4 | The same answer, harder | C4 density | 0.96 pp phone vs 0.87 pp fair, same n `(sim)` |

### Section 1 — Question (28 words)

The open question is not "was the poll wrong" but "can two thousand people speak for ninety million".
Lead with the number: the poll's margin at 2,000 interviews and p = 44.68% is **±2.18 points** `(proof)`.
The number that has to be explained is **19.29 points** of miss. The section states the two numbers and
stops; it does not preview the answer.

### Section 2 — Claim (22 words)

El-Rufai's sample-size sentence, quoted in full, attributed, linked, with the portrait beside it (§3).
The 22 words are the frame around the quote: who, when, where, and what he concluded. Nothing else.

### Section 3 — Counter-claim (32 words)

The disagreement must be a number, not a mood. His claim: 2,000 is too small. The counter: drawn from
the whole register, **500 interviews named the winner 3,967 times in 4,000**; drawn from phone owners,
**40,000 named it 0 times in 4,000** `(sim)`. Same simulation, same seed, same country — only the frame
changes. A reader who stops here has the argument.

### Section 4 — Setup (30 words)

The invented country, stated as assumptions, not as method: **90,000,000 registered**, six zones, four
colour-named parties, **31% phone reach** `(assume)` — his own figure, borrowed deliberately. One
sentence on why the country exists: the real election arrived three weeks late, so the answer is fixed
first here. No explanation of the simulation itself; that lives in the folded chunks.

### Section 5 — The simulation (50 words + four fig-caps)

The only section with charts, and the only one allowed sub-headings. Four blocks, each in the fixed
order: number sentence, chart, folded chunk. No prose explains how the country was built — the
`naijasim` chunk is the explanation, and it is folded. The section's single job is to show that the
failure is position, not width: C3 is the verdict, C1 is the cause, C2 removes the competing
explanation, C4 shows the phone frame is the *narrowest* wrong answer.

### Section 6 — Hommie's take (25 words)

The existing `.hommie` aside, unchanged: the pidgin question, then its answer ("Yes, and the five hundred
got it right, the forty thousand wrong, every time." — 14 words). It is the last word in the post and
nothing follows it, including no sign-off.

---

## 3. The quotes and the portrait

### The two quotes that survive

Quote 1 (section 2), verbatim, with the existing link to
<https://guardian.ng/news/el-rufai-debunks-obis-election-win-predictions-calls-opinion-polls-a-joke/>:

> Opinion polls are distorted... When you have about a 100 million registered voters and you are
> sampling 2,000 registered voters or 300 registered voters, your results from day one are unreliable;
> they will have high margins of error.

Quote 2 (section 3), verbatim — the objection that is actually right, and which the trimmed post cites as
the real one:

> Most of these polls, like the one by Bloomberg, ANAP and the one by Okonjo Iweala, all used
> telephone. What percentage of registered voters have phone numbers in INEC's records? We have found
> out and it's 31 per cent.

The `...` in quote 1 is el-Rufai's own trail-off as transcribed; keep it, do not smooth it into an
ellipsis or bridge it with words of mine.

Both quotes are **outside the word budget** (interview answer), and both keep their source link in the
prose as well as in the sources callout, so a reader can trace either one in one click.

Quote 3 (.hommie aside) already exists and stays:

> Dem ask 500 people and dem sabi? The other one ask 40,000 o.

### The portrait

| | |
|---|---|
| File | `File:Nasir Ahmed el-Rufai 2023.jpg`, Wikimedia Commons |
| Subject | El-Rufai, 25 February 2023 — three weeks after the TVC interview |
| Licence | **Public domain** (US federal work, Voice of America). Not CC; no share-alike obligation |
| Size | 470 × 662, 21 KB |
| Display | ~220 px wide, floated beside the quote in section 2 |

Vendor it into the post folder as `el-rufai-2023.jpg` — assets live beside `index.qmd`, and the site
never hotlinks (`CLAUDE.md`). Credit line in mono under the image: `VOA / Wikimedia Commons, public
domain`. The credit goes in the visible caption, not only in the callout, because a public-domain claim
is the kind of thing this site's own rules say should be traceable.

Check on download: the Commons page warns that VOA occasionally republishes wire photos. This file's
provenance is a VOA Africa YouTube upload, uploaded by a Commons editor, tagged PD-VOA — acceptable, and
recorded in the callout so the claim is auditable rather than asserted.

---

## 4. The four charts

Engine: **plotly, restyled** (interview answer), one per block in section 5, each computed by the chunk
directly above it. Keep `#| echo: false` on figure-only chunks. Every chart keeps the post's current
palette — `#0f766e` teal, `#0e7490` cyan, `#b45309` amber, `#6d28d9` violet, ink `#57606a` — so
"colourful, one accent for the answer" is satisfied by the party palette plus a single ink accent for
the truth line, not by a new scheme.

Charts must survive thumbnail size: line width 2.5, tick and annotation fonts ≥ 13, direct labels on the
data, legend killed where a direct label will do, `displayModeBar = FALSE`.

### C1 — A phone frame is a different country (5.1)

Grouped bars, four parties, two series: whole register, phone frame. Green reads 30.0% in the country and
37.0% through a phone; Blue 38.0% and 33.5%. Annotate in-plot: "frame: Green +3.5" and "country: Blue
+8". fig-cap, 16 words: *A phone frame is not a small copy: it is a different country that leans Green.*

### C2 — Pricing the objection (5.2)

SE against n, log x, one line for the poll and one for the same poll with the finite population
correction — the two lines coincide, which is the whole point. Shade the band between them; annotate at
n = 2,000: "0.0011%". No equation in the prose; the formula lives in the folded callout. fig-cap,
18 words: *Population size is worth 0.0011% of the margin: the correction is invisible at the scale he
complained about.*

### C3 — The ladder (5.3)

The money chart, and the one thing the current post does not have: winner-right against interviews, log
x, two lines — register (teal) climbing 64.1 → 84.8 → 96.5 → 99.2 → 100.0 → 100.0, phone frame (amber)
flat at 1.5 then 0.0. Direct value labels at every point. Arrow annotation on the phone line: "40,000
interviews, still 0". Kill the legend; the two lines are labelled at their right ends. fig-cap,
15 words: *Bigger spoon, same corner: 40,000 phone interviews name the winner no more often than 2,000.*

### C4 — The existing density figure, restyled (5.4)

Keep the figure that is already in the post — four curves, each scaled to its own peak, truth as a dotted
ink rule — and change only styling: thicker lines, direct labels at the peaks instead of a four-item
legend, larger fonts, annotation arrow pointing at the narrowest curve ("narrowest, and furthest from the
truth"). The ~80-point binning stays: it is the page-weight fix documented in `CLAUDE.md`, and the four
thousand raw draws must not ship. fig-cap, 14 words: *The phone frame is narrow, not wide: 40,000
interviews sit furthest from the truth.*

---

## 5. Word accounting

Counted: all body prose, the six headings, all four fig-caps, and any table cells.
Not counted: El-Rufai's two verbatim quotes, the visible photo credit, the sources callout, code.

| Item | Words |
|---|---|
| Sections 1–4 prose | 112 |
| Section 5 prose (50) + four fig-caps (63) | 113 |
| Section 6 aside | 25 |
| **Total** | **250** |

250 sits between the interview's 200 target and the 300 ceiling, with the slack deliberately in section
5, because that is where a chart needs one sentence of company and no more.

Sentence cap: 12 words, still enforced. Banned outright: "as we can see", "it is interesting", "in order
to", "note that", "essentially", "basically". Lead with the number. No paragraph may describe what a
chart already shows — with four charts this is the rule most at risk, and C3's caption already carries
its takeaway, so 5.3's prose adds only the frame/total comparison and stops.

Body table: **none.** The eight-rung ladder is a chart now, so the current five-column runs table is
deleted rather than shrunk to four rows. A table of 26 / 500 / 2,000 / 40,000 in "interviews, winner
right, so what" would be feelable and is the fallback if C3 proves unreadable at thumbnail size — decide
at build time, not both.

---

## 6. What is deleted

Everything below is cut, not rewritten. Git history is the archive.

- `## What he got right` / `## What he got wrong` — the scorecard of his claims, ~1,100 words with the
  conclusion and sources that follow it.
- `### What the objection is worth` as prose — its arithmetic survives only as C2 and one number.
- `### The size of the miss` as prose — the 17.3 SE derivation moves into the folded callout.
- `## Conclusion` and `### What this does not show` — the design-effect concession goes.
- The `inputs` / `shares` chunk narrative — chunks stay, their surrounding prose does not. The rebased
  44.68% vs actual 25.40% survives as one clause in section 1 or not at all.
- The `.dual` `.spine` / `.dub` block ("The translation", Gallup, the soup) — this is section 5 of the
  old structure and is replaced wholesale by the simulation.
- The sources callout's prose is reduced to a list of links; see §7.

---

## 7. Code law and chunk mechanics

```yaml
code-fold: true
code-summary: "Show the simulation"
```

in the post's frontmatter, overriding the project default `code-fold: show`. Every chunk folds; the four
figure-only chunks keep `#| echo: false`.

Chunks retained, in this order, with their labels and `stopifnot` guards intact:
`setup`, `inputs`, `shares`, `correction`, `distance`, `naijasim`, `naijasim-runs`, plus four new
figure chunks (C1–C4). Four of the current prose-heavy derivations lose their prose and keep their code.

One `::: {.callout-note collapse="true"}` at the end, titled "Where the numbers come from", holding: the
two standard-error formulas, the finite population correction, the margin inversion that produces 26, the
four source links (Guardian/TVC, ANAP press release, the Daily Post results breakdown, The Cable on
NOI/ANAP methodology), and the photo provenance. Symbols live only here; no equation appears outside it
and none appears in the body at all.

`::: {.aside-box .hommie}` closes the post, unchanged in content.

---

## 8. Frontmatter

Keep: `title`, `date: 2026-08-16`, `categories: [stats-in-life]`, `engine: knitr`, `image:
thumbnail.png`, `image-alt`, and both `image` comments.

Change `description:` to the claim, not the tour — roughly 35 words:

> Five hundred interviews drawn from the whole register named Nigeria's winner 3,967 times in 4,000.
> Forty thousand drawn from phone owners named it never. El-Rufai had the right objection and quoted the
> wrong one.

Add `code-fold: true` and `code-summary: "Show the simulation"`.

Leave `_thumbnail.R` and `thumbnail.png` alone. The palette is unchanged, so the thumbnail still matches,
and the script's `stopifnot` guards are what stop the two drifting.

---

## 9. Acceptance checks

1. `quarto render posts/how-big-should-the-spoon-be/index.qmd --no-freeze` succeeds; then a plain
   `quarto render ...` replays from the new freeze artifact.
2. With every fold closed, the six headings and the four fig-caps alone carry the argument. Read them in
   order and check that this is true; it is the request's own 60-second test.
3. Count words in the rendered HTML body, excluding `blockquote` and the credit line: ≤ 300.
4. No sentence exceeds 12 words. Check the four fig-caps too.
5. Every number in the prose carries `(sim)`, `(proof)` or `(assume)`. An untagged number is a defect.
6. Section 2 and 3 quotes match `origin/main` character for character.
7. Page weight of `_site/posts/how-big-should-the-spoon-be/index.html`: all four figures ship binned
   curves (~80 points each), so each plotly payload should stay in the tens of KB. If the HTML crosses a
   megabyte, a raw 4,000-draw matrix has leaked into a figure — the `CLAUDE.md` page-weight rule.
8. The portrait renders with its credit visible, at ~220 px, beside the quote, and the quote still sits
   above the fold at 390 × 844.
9. `quarto publish gh-pages` at the end, by me, on the user's authorisation. Leave the `.gitignore`
   lines it re-appends alone.

---

## 10. Where this departs from `New general rules.txt`

Six deliberate deviations, all from the interview, so that a later reader does not "fix" them back:

1. **Word cap raised.** The rules say ≤120 hard. The interview says "around 200 words, even 300 is fine".
   250 is the plan. Per-section caps are scaled up proportionally, not dropped.
2. **Section 5 is not "Maths / English."** Interview: "don't use maths". The `.dual` spine/dub pairing is
   deleted; section 5 becomes "The simulation", holding the charts. This is the largest structural
   departure and the one most likely to look like an oversight.
3. **Charts are not one per section 1–4.** Interview: "charts appear at simulation, under the right
   sections". Sections 1–4 carry a stat or a quote only; all four charts sit inside section 5, each under
   the chunk that computes it.
4. **Colour is not grey-plus-one-accent.** Interview: "maintain current colour scheme, make the post
   colorful". The four-hue party palette stays; the single ink accent marks the truth line. The rules'
   anti-rainbow line is overridden deliberately.
5. **Two quotes, not one.** The rules allow one. Section 2 quotes the claim, section 3 quotes the
   31% sentence, and the `.hommie` aside is a third voice — but the first two are the argument and the
   third is the existing component, not a pull-quote.
6. **Stat tags render as inline mono** — `(sim)`, `(proof)`, `(assume)` in code font, parenthetical,
   sitting after the number. Not chips; the theme has no chip component for this and inventing one is a
   theme change this task does not need.
7. **"Exactly one asset" is one stat-or-quote, not one object.** Section 2 carries the quote plus the
   portrait, and section 5 carries four charts; every section still has exactly one *number or quote*
   doing the arguing, which is the rule's purpose.

---

## 11. Left open

- **`date: 2026-08-16` is kept.** Whether a post cut to a quarter of its length should be re-dated is a
  publishing decision, not a formatting one.
- **The two local commits parked on `backup-local-pre-spoon`** are outside this task. `quarto publish`
  pushes `gh-pages`, not `main`, so `main` can stay where it is until someone decides what happens to
  that branch.
- **The scorecard's verdict** — that El-Rufai was right about the polls being wrong, right about the
  frame, wrong about the reason — survives only as the post's implicit structure after the cut. If that
  verdict matters, it needs its own short post rather than a paragraph here.
- **`stats-in-life`** is the category and stays; no `CATEGORIES.md` change.
