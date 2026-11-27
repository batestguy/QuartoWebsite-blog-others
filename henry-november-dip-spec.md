# Spec — Does form really dip in November?

**Short name:** `henry-november-dip`
**Slug:** `posts/thierry-henry-november-dip/` — permanent once published (`CLAUDE.md` rule 3)
**Status:** specification only. No post written, no scrape run, no render, no publish.
**Date:** 2026-11-27
**Source request:** "Thierry Henry made a claim about dip in form in November for players and thereby teams.
Study the El Rufai spoon script; we are now going to build something similar using right methods to check
Henry's claims." Clarified mid-session: **not simulation-driven**; use the analysis style of
`posts/nigeria-violence-2015-2025` — real data, calendar-month effects, effect sizes with intervals.

---

## 0. One-line answer

Henry's claim is empirical, so it is checked against observed player ratings, not simulated ones. The post
draws a **stratified random sample of 2,100 player-seasons** (25 per position per league per season) from
**seven leagues and three completed seasons**, compares each player's **November ratings with his own
other months**, and reports the November effect raw and adjusted, with a **pre-stated equivalence bound**
so that "no meaningful dip" is a possible finding rather than a failed test.

This is the Nigeria post's method, not the spoon post's: descriptive first, one model, numbers tagged
`(data)` / `(model)` / `(proof)`.

---

## 1. The claim, and what can honestly be said about it

**Source:** CBS Sports Golazo, *UCL Today*, YouTube Short `62jjflTCBh8`.
Title: *"Thierry recalls being warned by his national team coaches about the November dip in form"*
(<https://www.youtube.com/shorts/62jjflTCBh8>). Retrieved 2026-11-27.

That title is the source's own summary of the clip. It establishes three things and no more:

1. Henry was warned, by France's national-team coaches, about a **November dip in form**.
2. The claim is about **players** first, and teams by implication.
3. It is **received wisdom** — a recollection of a warning, not a published study, not a measured effect.

**The post must not invent a quote.** It quotes the clip title as the source's summary, names the show,
links the short, and says plainly that the full sentence is Henry's anecdote. If the user supplies a
transcript later, it replaces the title quotation verbatim; nothing else in the spec changes.

### The claim, operationalised

The post tests this, in these words, before showing any result:

> **H1.** A player's average match rating in November is lower than the same player's average in the other
> months of the same season.

Three consequences, each of which the post states:

- **"Form" is a provider's match rating**, a number between 1 and 10, not a latent truth. The post measures
  what pundits and fans actually argue about.
- **The team link is not tested.** Henry's "and thereby teams" is named in the conclusion as the part this
  post leaves open (interview round 4).
- **A dip seen is not a dip that exists.** November differs in fixtures, opponents, travel and who is
  available. That is the counter-claim, and it is what the adjustment is for.

---

## 2. Decisions taken in the interview

| Question | Decision |
|---|---|
| Simulation or real data | **Real data.** The spoon post is the wrong template; the Nigeria post is the right one |
| Unit | **Player ratings**, scraped, stratified by position and league (round 1) |
| Competitions | **All club competitions plus competitive internationals** (round 2) |
| Leagues | **Top five + three smaller:** England, Spain, Italy, Germany, France, Netherlands, Portugal (round 2) |
| Seasons | **2023-24, 2024-25, 2025-26** — the latest three completed (round 3) |
| Rating source | **Probe WhoScored and FotMob, then pick one** (round 3); single provider, no pooling |
| Minimum monthly exposure | **450 minutes in the month** (round 3) |
| Comparison | **Within player** — November against that player's own other months (round 3), chosen as the most defensible |
| Model | **Descriptive first, one adjusted model** (round 3) |
| Sample | **25 per position per league per season**, seeded random draw (round 5) |
| Internationals | **Competitive only** — Nations League, qualifiers, tournaments; no friendlies (round 5) |
| Goalkeepers | **In, as their own stratum** (round 5) |
| No-dip case | **Equivalence bound pre-stated** (round 5) |
| Figures | **Five or more** (round 5) |
| November absence | **Two analyses:** main excludes, sensitivity reports absence (round 4) |
| Team link | **Not tested**; named as open (round 4) |
| Data in repo | **Raw ratings CSV + scrape script** (round 4) |
| Claim text | **Clip title and context**, no invented quote (round 4) |
| Delivery | Write post + scripts + data, render, refresh freeze. **Do not publish** |

---

## 3. What carries over from the spoon post, and what does not

The spoon post's transferable idea is the **frame**, not the simulation: El-Rufai's objection was priced by
asking what a sample of a given size and frame can deliver. The analogue here is the player-month.

Carried over:

- A real-world claim restated as a testable quantity.
- A sample designed on purpose, with the design stated before results.
- Numbers tagged by provenance, so nothing is mistaken for evidence it is not.
- The `.hommie` aside at the end, in the same voice.
- Page-weight discipline: summarise before plotly.

Deliberately **not** carried over:

- Simulation. Henry's claim is about the observed world; simulating it would only restate assumptions.
- `(sim)` / `(proof)` / `(assume)` tags. This post uses `(data)` / `(model)` / `(proof)`, as Nigeria does.
- The 120-word law, the six fixed sections, and the TABLE LAW from `New general rules.txt`. That file is
  for the spoon post only (recorded in `standard-error-table-spec.md` and still true).

---

## 4. Data

### 4.1 Source gate: probe before writing

Two providers are technically available on this machine, and the interview chose the easier after a probe.

**FotMob** — JSON over HTTPS, no browser:

| Endpoint | Use | Verified 2026-11-27 |
|---|---|---|
| `/api/data/search/suggest?term=` | player id lookup | 200 |
| `/api/data/playerData?id=` | player metadata + recent matches, 20 per page, cursor in `initialMatchesPage.previous` | 200, 18 KB |
| `/api/data/matchDetails?matchId=` | lineups, both teams, rating at `content.lineup.{homeTeam,awayTeam}.starters[].performance.rating` | 200, 25 KB |

- Ratings are **not** on the player match list (`rating: None`); they exist only in `matchDetails`, which
  means **one request per match**, not one per player.
- League list: `/api/data/leagues?id=…` returns `allAvailableSeasons`; season and league IDs must be
  resolved at build time, never hardcoded from memory.

**WhoScored** — HTML behind Cloudflare:

- Loads successfully in **headed Chrome via Playwright** (verified: `/Statistics` returned the team table
  with a `Rating` column, e.g. 7.08). Headless was not tested as a requirement; treat headed as the
  working mode.
- Ratings live on player pages and match centre pages; fewer pages than FotMob's per-match calls, but the
  scrape is browser-bound and must be rate-limited.

**Probe protocol (one league-season, Premier League 2025-26):**

1. Fetch the player frame for the season (all players, appearances, minutes, position).
2. Fetch ratings for 20 randomly chosen matches.
3. Record: share of starters with a non-null rating, share of substitutes with one, request count per
   match/player, wall-clock, blocking events, and whether the competition label is present.
4. Pick the provider with **≥95% starter coverage and the lower total request count**; ties go to FotMob
   (HTTP, no browser). Record the choice and the probe numbers in the post's callout.

If neither provider reaches 95% starter coverage for 2025-26, stop and report rather than lowering the
coverage bar silently.

### 4.2 Sampling frame and design

**Unit:** player-season. One row per (player, season) in the analytic sample.

**Frame per league-season:** every player in the provider's season table with **≥450 minutes in that
season**, with position and club.

**Strata:** league (7) × position (4: GK, DF, MF, FW) × season (3) = 84 strata.

**Draw:** **25 players per stratum, without replacement**, seeded at `20261127`. If a stratum has fewer
than 25 eligible players, take all and record the shortfall. Expected analytic size **2,100 player-seasons**
(84 × 25); expect ~1,400–1,700 distinct players, since a player can be drawn in more than one season.

**Why sample at all when the scrape may cover the whole league:** the 25-per-stratum allocation is a
**balanced design**, not a cost shortcut. It stops the big leagues and the midfielders from dominating the
pooled estimate and makes every stratum contribute equally. State this in the post — a reader who assumes
"random sample" means "representative of all professionals" would otherwise misread it.

**Position mapping:** use the provider's coarse position. If it gives detailed roles, map
GK→GK; centre-back, full-back, wing-back→DF; defensive/holding/central/attacking midfield, wide
midfielder→MF; winger, second striker, striker→FW. Publish the mapping and the per-stratum counts; a
lopsided mapping is visible and correctable before analysis.

### 4.3 Competitions counted

Included:

- Domestic league (all seven).
- Domestic cup.
- European club competition (Champions League, Europa League, Conference League), qualifying rounds
  included.
- Competitive internationals: Nations League, World Cup and continental qualifiers, continental finals,
  World Cup finals.

Excluded: friendlies, pre-season, exhibition and age-group matches.

Every rating row carries a `competition_type` in {league, cup, europe, international} so the post can show
whether any November effect is driven by one type.

### 4.4 Exposure rule

A rating enters a **monthly average only if the player accumulated ≥450 minutes in that calendar month**.
The same rule applies to every month, so November is compared with months built the same way.

Consequences to state in the post, not bury:

- 450 minutes is roughly five full matches. In a November containing an international break this selects
  **regular starters**, not squad players.
- The estimate therefore describes regular starters who were available in both November and the comparison
  months. It does **not** describe all professionals, and it cannot see a player who lost his place.
- The sensitivity analysis in §5.2 exists for exactly that reason.

### 4.5 Stored fields and files

`data/ratings.csv` — one row per player-match:

| Field | Type | Note |
|---|---|---|
| `provider` | text | one value; no pooling |
| `player_id`, `player_name` | text | provider ids are stable within a season |
| `season` | text | `2023-24`, `2024-25`, `2025-26` |
| `league` | text | canonical league name |
| `competition_type` | factor | league / cup / europe / international |
| `match_id`, `match_date` | text, date | UTC date, converted to local competition date before month assignment |
| `team`, `opponent` | text | canonical names |
| `home` | logical | |
| `position` | factor | GK / DF / MF / FW |
| `started` | logical | |
| `minutes` | numeric | 0–120 |
| `rating` | numeric | provider scale, 1–10; NA if unrated |
| `team_rating` | numeric | provider's team rating for that match, where available |
| `opponent_strength` | numeric | pre-computed season points-per-game of the opponent, all competitions |
| `source_url`, `retrieved_at` | text | audit trail |

`data/player_month.csv` — derived, one row per player-season-month with ≥1 appearance:
minutes, raw mean rating, minutes-weighted mean rating, appearances, share of 450 reached, competition mix.

`data/PROVENANCE.md` — provider, endpoints, retrieval dates, request count, seed, sample counts per
stratum, coverage checks, and the licence/ToS note.

Raw provider JSON is cached under `.cache/` and **not committed**; the derived CSVs are.

### 4.6 Cleaning checks (fail the build, do not warn)

- `rating` in [1, 10] or NA; `minutes` in [0, 120].
- No duplicate `(player_id, match_id)`.
- Every sampled player has ≥1 row in every season drawn; every row's player is in the sample.
- Match dates parse; month assignment uses the local date, not UTC.
- Starter coverage per league-season ≥95% (the probe bar) on the full scrape.
- Position mapping leaves no unmapped player.
- The same player's club does not change mid-season without a transfer row (record, do not drop).

---

## 5. The two analyses

### 5.1 Main: each player against himself

**Estimand:** the mean within-player difference between a player's November rating average and his
average across the other months of the same season, among player-seasons meeting the 450-minute rule in
November and in at least three other months (a season-long regular, roughly 20 full matches in total).
If fewer than 60 per cent of sampled player-seasons clear that bar, relax to **two** other months and
report the looser rule alongside; do not relax it silently after seeing the estimates.

Two estimates, both reported:

1. **Descriptive:** the distribution of within-player differences, with a mean and 95% interval; plus the
   twelve-month curve, indexed to each player's own season mean (so the shape is not a composition
   effect).
2. **Adjusted:** the November coefficient from the mixed model in §6, with the same 95% interval.

**Headline number:** the adjusted November effect in rating points, with its interval, and the equivalence
verdict from §6.3.

### 5.2 Sensitivity: who disappears in November?

The main analysis excludes players who did not reach 450 minutes in November. That exclusion is itself a
possible manifestation of a dip, so it is reported rather than assumed away (interview round 4).

Two pieces:

- **Participation:** for every sampled player-season, whether the 450-minute threshold was reached, by
  calendar month. Fit a binomial mixed model with month and position, player random intercept. Report the
  November participation rate against the other months.
- **Worst-case rating bound:** for player-seasons short of 450 minutes in November, impute the **10th
  percentile** of that player's own other-month ratings, then recompute the main estimate. This is a
  deliberately pessimistic bound; if the effect survives it, the exclusion is not driving the result. If
  it does not, the post says the verdict depends on how absent players are counted.

Both go in the post, in the same section or a clearly marked subsection. Neither replaces the headline.

---

## 6. Model, inference, and the no-dip case

### 6.1 Specification

```r
rating ~ november + position + league + season + home +
         opponent_strength + minutes + competition_type +
         (1 | player_id) + (1 | match_id)
```

- `november` is the pre-specified contrast; every other term is adjustment.
- `(1 | player_id)` handles repeated player-seasons and repeated players across seasons.
- `(1 | match_id)` handles the fact that ratings within a match share conditions.
- Fit with `lme4::lmer` (1.1.37, installed). If singular, drop `(1 | match_id)` and report that.
- Robustness: player-season fixed effects (within transformation) as an alternative to the random
  intercept; report both, headline on the random-intercept model.
- A second specification adds `november:league` and `november:position` for the subgroup figure. These are
  **exploratory**, Benjamini–Hochberg adjusted across the 28 league×position cells, and never the headline.

### 6.2 What adjustment can and cannot mean

Ratings already embed team performance and opponent quality. Adjusting for opponent strength therefore
risks **over-controlling** the very mechanism Henry is describing. So:

- Report **raw** and **adjusted** November effects side by side.
- If adjustment moves the estimate materially, say which direction and why, rather than choosing the
  prettier one.
- No causal language. "Associated with" and "the data are/are not consistent with" only.

### 6.3 Equivalence bound, stated before results

**Smallest dip that would matter: 0.10 rating points** on the provider's 1–10 scale.

Justification to include: match-to-match rating SD is roughly 0.6–0.8 (verify it from this dataset and
report the measured value); 0.10 is about a seventh of that, smaller than typical position or team
differences, and visible to a reader of ratings to one decimal place. A dip smaller than that is not what
a pundit means by "form drops". If the measured SD is far from that range, the **rationale** is
recomputed from the data, but the bound stays 0.10 unless the user changes it.

**Decision rule:**

| Result | Post says |
|---|---|
| 90% CI entirely below −0.10 | A meaningful November dip is present |
| 90% CI entirely inside ±0.10 | No meaningful dip; the data exclude one of the size claimed |
| Otherwise | Inconclusive: the data are compatible with a small dip and with none |

Use **90% CI for the equivalence test** (the standard TOST convention) and **95% CI for estimation**.
Both appear in the same sentence; do not substitute one for the other silently.

### 6.4 Multiple comparisons

One headline contrast. The 28 subgroup estimates and the three season-specific estimates are secondary
and BH-adjusted. No "best subgroup" claim; if one league shows a dip, the post says it is one of 28 looks.

---

## 7. Post structure and figures

Mirror `posts/nigeria-violence-2015-2025/index.qmd` exactly in shell, not in content:

1. `## Question`
2. `## Claim` — the clip, the warning, the operational claim; one portrait/photo with credit.
3. `## Counter-claim` — the two rival explanations: fixtures/opponents and availability.
4. `## Setup` — provider, seasons, leagues, strata, 450 rule, tags explained.
5. `## The analysis` — five or six `###` blocks, each number → chart → folded method.
6. `## Where the numbers come from` — callout, `collapse="true"`.
7. `## The formulas, said twice` — `.dual` spine/dub pairs for the monthly average, the within-player
   contrast, the mixed model, and the equivalence rule.
8. `.aside-box .hommie` — the closing aside, same voice as the other posts.

**Figures (five, plus one optional):**

| # | Figure | Carries |
|---|---|---|
| F1 | Twelve-month curve, indexed to each player's own mean, November highlighted, 95% band | Whether there is a visible dip at all |
| F2 | Distribution of within-player November differences, zero and ±0.10 bounds marked | The size of the dip against the noise |
| F3 | Forest plot: raw effect, adjusted effect, season-by-season, worst-case bound | How the verdict moves with specification |
| F4 | League × position subgroup estimates, BH-adjusted, November marked | Where the effect lives, and the multiple-comparison caveat |
| F5 | Participation by month: share reaching 450 minutes, November highlighted | Who disappears, the selection story |
| F6 (optional) | Competition-type split (league / cup / Europe / international) | Whether congestion or context drives it |

Chart rules, from the repo and the Nigeria post: plotly, `displayModeBar = FALSE`, direct labels over
legends, one accent colour for November and the verdict, muted grey elsewhere, fonts ≥12, `fig-cap` states
the takeaway rather than the axes, and **only binned/summarised points are shipped** — never per-match rows
(`CLAUDE.md` page-weight rule).

**Prose:** no word cap. The Nigeria post's register: short declarative sentences, number first, every
number tagged `(data)`, `(model)` or `(proof)`.

---

## 8. Post shell

```yaml
---
title: "Does form really dip in November?"
description: "A stratified sample of 2,100 player-seasons across seven leagues says whether November ratings fall below the same player's other months — and whether the fall is bigger than the noise."
date: 2026-11-27
categories:
  - stats-cases
tags:
  - player ratings
  - form
  - workload
  - mixed models
  - scraping
engine: knitr
code-fold: true
code-summary: "Show the analysis"
image: thumbnail.png
image-alt: "Twelve monthly rating points with confidence bands and November highlighted, showing where the year's low and high points fall."
---
```

- `stats-cases` is the correct stream: a real-world claim checked against data, not a prior simulation.
- Tags are topics a reader would search, not the stream.
- Slug fixed as `thierry-henry-november-dip`; do not rename after publish.
- **Photo:** a licensed portrait of Henry is preferred, but licence comes first. Only PD or CC with
  attribution, vendored into the post folder, credit in the visible `figcaption`, licence recorded in the
  callout. If no acceptable Henry image is found, use a public-domain November football photograph and say
  in the caption that it is not Henry. Never hotlink, never ship an uncredited news photo.
- **Thumbnail:** `_thumbnail.R` builds a static PNG from the same data with the same `stopifnot` guards as
  the post, so the listing image cannot drift from the figure.

---

## 9. Files and repo changes

```
posts/thierry-henry-november-dip/
  index.qmd
  scrape.py            # probe + full scrape, resumable, rate-limited
  build_data.py        # cleaning, checks, monthly aggregation
  analysis.R           # models, cached fits, figure data
  _thumbnail.R
  thumbnail.png
  data/
    ratings.csv        # player-match, committed
    player_month.csv   # player-season-month, committed
    PROVENANCE.md
  cache/               # fitted model .rds, committed like the Nigeria post
```

- **One engine in the post:** R (`knitr`). Python is confined to the two scripts; no Python chunks, so the
  `engine` chip reads `R` correctly.
- The scrape runs against `E:\Miniconda3\python.exe` (3.13.9) on this machine; `ds-general` is the
  registered kernel but the post does not need it. Do **not** install packages into the project folder.
- `data/ratings.csv` is expected in the low single-digit MB for 2,100 player-seasons. If it exceeds
  ~10 MB, gzip it and keep the loader explicit; do not silently commit a 50 MB file.
- `_freeze/` refreshed after rendering, committed. A plain `quarto render` on the post thereafter replays.
- **Do not publish** in this task.

---

## 10. Acceptance criteria

- [ ] Provider probe run and recorded; chosen provider has ≥95% starter coverage on the probe season.
- [ ] Sampling reproducible from the seed; stratum counts sum to 2,100, shortfalls listed.
- [ ] `ratings.csv` and `player_month.csv` regenerate from the committed scripts against the cached
      provider data; every number in the post comes from `analysis.R`, none typed.
- [ ] Main within-player estimate with 95% interval, raw and adjusted, in rating points.
- [ ] Equivalence verdict stated using the pre-registered ±0.10 bound and the three-way rule in §6.3.
- [ ] Participation analysis and worst-case bound both reported.
- [ ] 28 subgroup estimates BH-adjusted and labelled exploratory.
- [ ] Five figures present, all server-side summarised, page under 1.5 MB.
- [ ] Every number tagged `(data)`, `(model)` or `(proof)`.
- [ ] Photo licence and credit visible; thumbnail matches the figure.
- [ ] Post follows the Nigeria shell; `.hommie` aside closes it.
- [ ] `posts/thierry-henry-november-dip` renders with exit 0 and the freeze artifact is committed.
- [ ] No theme files touched; no other post changed; no publish.

---

## 11. Risks and limitations to state in the post

1. **Ratings are a provider's judgement.** They are not a physical measurement; the post says whose scale
   it is using and that a different provider could shift levels. The probe and a one-league cross-check
   are the only defence.
2. **The 450-minute rule selects regular starters.** Squad players and players who lost their place are
   invisible to the headline. The absence analysis is the partial remedy, not a full one.
3. **November is not a clean treatment.** It contains an international break, European midweeks, cup
   rounds and weather. Adjustment cannot separate all of it; the competition split is descriptive, not
   causal.
4. **Three Novembers.** Three seasons give three observations of the month at league level; the pooled
   estimate is driven by player-months, not by many independent Novembers. No claim about trends over the
   decade.
5. **Ratings depend on the team and the opponent.** Good players in bad teams rate lower; the adjustment
   may remove part of the effect. Raw and adjusted are shown together for that reason.
6. **Scraping is fragile and provider-dependent.** Endpoints change; the committed CSV is the record.
   Rate limits are respected; no parallel hammering; failures are retried with backoff and logged.
7. **Licensing/ToS.** The ratings are the provider's data. Committing the derived CSV was chosen in the
   interview; if the provider's terms forbid redistribution, fall back to committing only
   `player_month.csv` plus the script and say so in `PROVENANCE.md`.
8. **No causal claim, and no team claim.** The post tests the player link only. "Thereby teams" is named as
   the next question, not answered.

---

## 12. Deferred, with a trigger

- **Team-level test.** If the player effect is present and the reader wants the second link, a follow-up
  joins team results and tests November points/goals with the same design. Not this post.
- **Second provider cross-check.** Only if the probe is close or the result is surprising; a full
  two-provider comparison was declined as more work than the claim needs.
- **Current season 2026-27.** Excluded as partial. Revisit in June 2027 when it is complete.
- **Friendlies.** Excluded by decision; if international coverage proves thin without them, report the gap
  rather than quietly adding them.
- **Correction for fixture congestion.** A matches-in-last-14-days covariate is tempting and was not
  chosen; add only if the adjusted and raw estimates disagree in a way that needs explaining.

---

## 13. Implementation order

1. Resolve league and season ids for both providers; run the probe on PL 2025-26 (§4.1).
2. Choose the provider; write `scrape.py` with resume, backoff, and per-request logging.
3. Build the frame, draw the stratified sample with seed `20261127`, freeze the sample list to
   `data/sample.csv` before scraping (so the draw cannot be re-rolled after seeing results).
4. Scrape; run cleaning checks; write `ratings.csv`, `player_month.csv`, `PROVENANCE.md`.
5. Write `analysis.R`: monthly aggregation, within-player contrasts, mixed models, equivalence test,
   participation model, cached fits.
6. Write `index.qmd` around the results, using the Nigeria shell; build figures from summarised data.
7. Render the single post; check the page and the five figures at 390 px and desktop.
8. Refresh `_freeze`, commit post + scripts + data + freeze. Do not publish.

**Stop point for this task:** this file. No implementation until the spec is approved.
