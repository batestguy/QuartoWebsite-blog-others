# Spec — Which Nigerian states got worse, and their deadliest months

**Short name:** `nigeria-conflict-methods`
**Status:** specification only. No code written, no repo files changed.
**Date:** 2026-11-04
**Source request:** "These two hypotheses are the most interesting ones we will look at; research what method will answer these questions best for us in ML/DL or traditional stats."

---

## 0. One-line answer to the request

**Traditional statistics wins, and the ML arm is a scored control rather than a contender.** The
evidence is unusually direct: the ViEWS 2023/24 prediction-competition contribution found a
**negative binomial beat both a hurdle model and feed-forward neural networks** on monthly conflict
fatalities by CRPS for 2018–2021, with NNs superior only on the later 2022–2023 test years — on
~37 states × 11 years the neural route has nothing to learn from. What the data needs is not more
capacity but a **hierarchical negative-binomial GLMM with state-varying slopes** (partial pooling),
scored with AIC for structure and CRPS on a held-out 2026 for the predictive claim. Deep learning
is excluded on evidence, not taste.

---

## 1. The two questions

### Q1 — Which states have got worse over time?

**Substantive claim:** the national "it is getting worse" headline is a poor summary. The country
contains at least two trajectories, and the states worsening fastest are not the states already
worst.

**Evidence already established in the exploratory pass** (Poisson trends per state, 2019–2025,
dispersion-adjusted, empirical-Bayes shrunk):

- National trend **+13.8%/yr**, between-state SD **11.0 percentage points** — the spread of state
  trends is nearly as large as the trend itself.
- **15 of 37 states worse, 22 flat, 0 improving** (no state's interval lay wholly below zero).
- Fastest (shrunk): Sokoto **+47.3%**, Kebbi **+34.8%**, Zamfara **+34.1%**, Katsina **+30.7%**,
  Plateau **+28.3%**, Kwara **+27.8%**, Benue **+27.4%**.
- **Borno — the deadliest state — is flat** (+6.5%, CI −2.5 to +14.3). Kaduna (+8.5), Niger (+14.0),
  Adamawa (+4.5) flat too.
- Shrinkage changes the headline: raw slopes rank Kwara first (+51.9) and Sokoto second (+51.7);
  shrunk, Sokoto leads. Gombe drops out of the "worse" set entirely (+29.1 raw → +19.9 shrunk,
  interval touching zero).

### Q2 — The most dangerous months, per state and per LGA, for all outcomes

**Substantive claim:** frequency and lethality are different conflicts, so "most dangerous month"
has no single answer — and which month you name depends on whether you define danger as the observed
maximum, the probability of being worst, or the risk of crossing a catastrophe threshold.

**Evidence already established:**

- Top 12 state-months by deaths, 2019–2026: **11 are Borno, 92.8% of the deaths in the table.**
- The single exception: **Niger, March 2022 — 491 deaths from 28 events (17.5 deaths/event).**
- The deadliest LGA-months split into two signatures:
  - **Niger / Mariga, March 2022: 302 deaths from 5 events (60.4/event).**
  - **Niger / Minna, January 2022: 227 deaths from 2 events (113.5/event).**
  - **Borno / Gwoza, April 2026: 228 deaths from 36 events (6.3/event).**
- Rank correlation between event frequency and deaths-per-event is only **0.50** (events vs total
  deaths is 0.935) — they are measuring different things.
- Civilian-targeting share 2025: **0.85 Kano … 0.28 Borno**.
- Seasonality: **events flat by calendar month** (288–320/month, no pattern); **deaths not flat** —
  January–June ≈ **905 deaths/month-year**, July–October ≈ **700**, ratio **1.22**, on equal years
  (2019–2025). Per state, the deadliest month of the year falls in **January–May for 29 of 37**
  states; April (8) and May (7) lead; September and October never do.
- Four outcomes to be covered: `pv_events`, `pv_fatalities`, `ct_events`, `ct_fatalities`.

---

## 2. Data

**Source:** Kaggle `justtryit01/nigerian-insecurity-analysis-1997-2026` (MIT licence, updated
2026-08-20, 10.8 MB), compiled from **ACLED** (1997–2026) and **UCDP** (1990–2024) via HDX.
File used: `acled_cleaned.csv`. Reserved alternative: `janeodum/acled-nigeria` — 27,990 raw ACLED
events 2019–2026 with `actor1`/`event_type`, licence "Unknown" on Kaggle (so ACLED's own terms),
needed only if actor-level claims are ever required.

**Structure (verified, not assumed):**

| Property | Value |
|---|---|
| Grain | one row per (state, LGA, year, month) |
| Rows | 273,288 = **772 state-LGA cells × 354 months**, perfectly balanced |
| Span | January 1997 → June 2026 (354 consecutive months) |
| States | 37 (36 + FCT) |
| LGAs | 765 distinct names, **772 cells** — 7 names repeat across states, so `(state, lga)` is the key |
| LGAs per state | 6 (FCT) … 44 (Kano) |
| Zeros | **92.9%** of rows have `pv_events == 0` |
| Nulls / duplicates / negatives | 0 / 0 / 0 |
| Totals | 37,222 events; 142,158 deaths; 55.9% of events and 44.4% of deaths civilian-targeted |

**Variables:** `state`, `lga`, `month` (text — must be mapped to 1–12), `year`, `pv_events`,
`pv_fatalities`, `ct_events`, `ct_fatalities`.

**Verified relationships:** `ct_*` is a strict subset of `pv_*` in every row (0 violations) — model
it as a share, never add it to `pv`. Exposure is constant by construction (all cells observed for
the same months), so **no offset column is needed**.

**What is absent:** actors, `event_type`/`sub_event_type`, exact dates, coordinates, population or
area, geopolitical-zone column, election flags. Consequences: "banditry vs Boko Haram" is **not
answerable** from this file; per-capita rates need an external population join; zones must be added
by hand.

**Analysis window:** fit **2015–2025** (132 months → **101,904 rows**), hold **2026** (Jan–Jun,
**4,632 rows**) out entirely, and use it as validation throughout. 2026 is genuinely six months —
not missing data: Jan–Jun have 772 × 30 = 23,160 rows, Jul–Dec 772 × 29 = 22,388.

**Data caveats to state in the post:** ACLED coverage deepens over time, so early years are a
different reporting regime; June 2026 is thin (131 events vs May's 643) and must not be read as a
collapse; recent ACLED months are revised; fatality counting in mass-casualty banditry is less
reliable than event counting; no population offset means "worse" is per-area, not per-capita.

---

## 3. Methods reviewed

### 3.1 Literature — the closest precedents

| Source | What it establishes | Consequence here |
|---|---|---|
| **Bodentien & Rüter, ViEWS 2023/24 prediction competition** (2024, rev. Jan 2026) | NB vs hurdle vs feed-forward NN for **monthly conflict fatalities**, scored by CRPS. NB (simplest) won 2018–2021; NNs won 2022–2023 | Direct licence for NB-first, with a *scored* ML control rather than a DL headline |
| **ACLED CAST** methodology | ACLED's own production system is "a hierarchical forecasting model that leverages machine learning to predict organized violence events at multiple spatial levels" | Hierarchy across spatial levels is the field's production standard, not a novelty |
| **Abebe, Seid, Roininen & Ali (arXiv 2511.00867, Nov 2025)** — Ethiopia, ACLED 1997–2024 | Dual Bayesian model: binary occurrence **plus** count of fatalities; INLA; Matérn spatial field; season covariate; population offset. Finds "higher likelihood of multiple fatalities in summer" | Nearest structural precedent to **Q2**. Its hurdle pair is exactly the "count-plus-severity" shape we test |
| **Browning et al., JRSS-A (2026)** | Bayesian spatiotemporal modelling of political violence | Confirms spatiotemporal structure as the current journal-standard framing |
| **Brandt & Williams (1998, 2001)** — PCETS / pewma | Dynamic event-count models (ARMA + NB) for persistent political event series | Precedent for time-varying count models; supports our year term over raw year-over-year ratios |
| **Bagozzi et al.** — zero-inflated count models for civil-conflict forecasting | ZINB/hurdle evaluated against NB for conflict counts | Justifies testing all three families against the 93% zero problem |
| **Clauset, Shalizi & Newman (2009)**; **Spagat & van Weezel (2020)**; **Cirillo & Taleb (2016)** | Casualty sizes are heavy-tailed (war-level exponent ≈ 1.5–1.7); extremes are not tail-noise | Grounds the **exceedance** definition of danger: the tail is the phenomenon, not an outlier |
| **Hyndman & Athanasopoulos, FPP3 ch.11** | Hierarchical/grouped series, aggregation constraints, optimal reconciliation | LGA → state → national is a coherent hierarchy; our estimates should not violate it |

### 3.2 Books

- **Gelman & Hill, *Data Analysis Using Regression and Multilevel/Hierarchical Models* (2007)** —
  the canonical partial-pooling text; the no-pooling / complete-pooling / partial-pooling triad the
  post is built on.
- **McElreath, *Statistical Rethinking* (2nd ed.), ch. 12–14** — multilevel models and the
  divergences/shrinkage intuition.
- **Bayes Rules!, ch. 17** — random intercepts *and* slopes in a hierarchical regression, the
  closest textbook exposition of model M3 below.
- **Hyndman & Athanasopoulos, *FPP3*, ch. 11** — hierarchical forecasting and reconciliation.
- **BDA3, ch. 15** — hierarchical model machinery (referenced, not required, given the
  frequentist decision).

### 3.3 Blogs

- **Andrew Heiss, "A guide to working with country-year panel data and Bayesian multilevel models"
  (2021)** — the practical brms/TSCS recipe: random intercepts, random slopes, regional trends;
  and it points at **Michael Clark's mixed-models guide** (random effects, common extensions) and
  **Solomon Kurz's brms translations** of McElreath ch. 12 / Singer & Willett.
- **PyMC "A Primer on Bayesian Methods for Multilevel Modeling"** — the pedagogy for
  hierarchical/partial pooling (radon example), reusable structure for our shrinkage figure.
- **Michael Clark, mixed models with R** — the "more random effects / common extensions" sequence.
- **Rob Hyndman's hierarchical-forecasting material** — reconciliation, if LGA→state coherence is
  enforced.

### 3.4 Methods considered and rejected

| Method | Why rejected |
|---|---|
| **DeepAR / Temporal Fusion Transformer / N-BEATS** | 37 states × 126 months is far below the data regime these need; `torch`, `gluonts`, `jax`, `numpyro` are all absent from `ds-general`; and the ViEWS evidence says NNs only beat NB on the later test years |
| **Full Bayesian posterior with rank probabilities (brms/CmdStan)** | Best answer to "P(this month is worst)", but the user chose a frequentist spine; rank uncertainty is recovered instead by parametric bootstrap. **Available and installed** (`brms` 2.23, CmdStan 2.38.0) as a documented fallback |
| **INLA / SPDE spatial field** | Requires an install and a Bayesian engine; replaced by `mgcv` `bs="mrf"` areal smooth, which is frequentist and needs no install |
| **LOO / WAIC model comparison** | Considered in interview round 1, then **superseded** in round 3 by **AIC/BIC**, which is the coherent frequentist choice |
| **LSTM / GRU sequence models** | Same data-regime objection as DeepAR, plus no `torch` |
| **Change-point detection per state** | Attractive for "when did it get worse", but with 37 states it invites 37 independent change-points and a multiple-comparison mess; out of scope |
| **Spatial regression with real polygons (sf/terra)** | No Nigeria shapefile in the repo; adjacency would have to be hand-coded or downloaded. Left as an open question (§10) |

---

## 4. Recommended method

### 4.1 Q1 — state-varying trends

**Engine:** `glmmTMB` (installed, 1.1.15.2), negative binomial. Main model fitted at
**LGA-within-state** resolution, reported at state resolution.

Model sequence, compared by **AIC**:

| ID | Specification | Purpose |
|---|---|---|
| M0 | `pv_events ~ year`, NB2, offset `log(months)` | complete pooling — the naive baseline |
| M1 | `+ factor(state)` | no pooling — the conventional "just add dummies" answer |
| M2 | `+ (1 | state)` | partial pooling on level only |
| M3 | `+ (1 + year | state)` | **Q1's model** — state-varying slopes (random slope on year) |
| M4 | `+ (1 | state/lga) + (1 + year | state:lga)` | full hierarchy — LGA nested in state, with LGA slopes |

Then the *family* comparison asked for in interview round 2 — **all three, compared**:

- `family = nbinom2` (negative binomial; the ViEWS winner),
- `family = nbinom2, ziformula = ~1` (ZINB),
- `family = truncated_nbinom2` with `ziformula` (hurdle),
- plus plain `poisson` as the deliberately-naive baseline showing overdispersion breaking it.

**Spatial check (one fit only):** `mgcv::bam()` with `s(state, bs = "mrf", xt = list(nb = adj))`
plus `s(state, bs = "re")` and `s(year, state, bs = "re")`, on the state-month aggregate. Purpose is
narrow: does letting neighbouring states borrow strength change the trend ranking? If yes, say so;
if no, say that too — that is a finding.

**Reporting:** per-state trend as %/yr with 95% CI, ordered, as a caterpillar plot; national trend
for reference; ΔAIC table for M0–M4 and for the four families; dispersion check
(`performance::check_overdispersion`, `DHARMa` installable if needed).

### 4.2 Q2 — deadliest months

Same NB GLMM at LGA-month resolution with `(1 | state/lga)` plus **month-of-year factor** and year,
so each LGA-month has a fitted rate and a predictive distribution. Three definitions, all reported
and **compared** (interview round 1):

1. **Argmax** — the observed worst year-month per LGA and per state, per outcome, with an interval
   from the parametric bootstrap.
2. **P(rank first)** — parametric bootstrap from the fitted NB: simulate replicate panels, refit
   (or recompute cell rates), and count how often each month ranks worst. This is the frequentist
   substitute for the Bayesian rank probability and is what answers "is this really the worst, or
   noise?".
3. **Exceedance** — P(deaths > τ) per month from the fitted NB predictive distribution, with τ stated
   explicitly (e.g. the 95th percentile of observed LGA-months). *Default: NB predictive
   exceedance, no extra package.* A peak-over-threshold / GPD fit via `extRemes` or `evd` is the
   more principled alternative and is **installable** — open question §10.

**Deliverable for this question is the disagreement**, not a single list: the three definitions will
not agree, and showing where and why is the point.

### 4.3 The ML/DL control arm

**LightGBM (4.7.0, installed), quantile objective**, as chosen in round 3:

- One model per outcome (4), quantiles 0.05 … 0.95, CRPS approximated from the quantile ensemble.
- **Leakage discipline:** features must be knowable *before* the month being predicted — state/LGA
  identity, month-of-year, lagged counts and rolling means at ≥1 month lag. No contemporaneous
  values, no future aggregates.
- Trained on 2015–2025, scored on 2026 alongside the GLMM, on the same CRPS.

The honest expectation, from ViEWS: the GLMM matches or beats it. The point of including it is that
the claim is *measured* here rather than asserted.

### 4.4 Evaluation protocol

- **Structure:** AIC (and BIC as a robustness aside) across M0–M4 and across families.
- **Predictive:** CRPS on the held-out **2026** months, GLMM vs LightGBM, for the outcomes where a
  distributional comparison is meaningful.
- **Calibration:** PIT / interval coverage on 2026 — a sharp model that is mis-calibrated gets
  reported as such.
- Six held-out months is a **small** test set: every CRPS claim carries that caveat, and no
  significance test is run on six months of scores.

---

## 5. The three "worse" definitions (round 3)

Round 3 asked for **all three, and the list shown changing**:

1. **CI excludes zero** — the conventional rule.
2. **CI excludes zero *and* ≥ +10%/yr** — statistically detectable and substantively large.
3. **CI excludes zero after Benjamini–Hochberg FDR** across the 37 states.

The post reports the three state lists side by side and shows where they differ. The number of
"worse" states is then explicitly a function of the rule — which is itself the finding.

---

## 6. Deliverable and repo changes

**Post:** `posts/nigeria-violence-2015-2025/index.qmd`
- slug **`nigeria-violence-2015-2025`** (chosen in round 5; permanent once published)
- `categories: [stats-cases]` — the only valid stream slug for this content
- `engine: knitr` (R post; one engine per post is a repo rule)
- `description:` must be the **claim**, not a teaser (repo convention)

**Reusable script:** `posts/nigeria-violence-2015-2025/analysis.R`, **sourced by the `.qmd`** in a
setup chunk (round 4), so figures cannot drift from the script. Every model fit is wrapped in a
cache: results written to `posts/nigeria-violence-2015-2025/cache/*.rds` and reused when present, so
a re-render is cheap and `--no-freeze` recomputes everything.

**Data committed:** the **full LGA-month panel, 2015–2026** (round 4) — 106,536 rows
(101,904 + 4,632), roughly 2–2.5 MB as CSV, at
`posts/nigeria-violence-2015-2025/data/acled_clean_lga_month.csv`, plus a short `PROVENANCE.md`
naming the Kaggle dataset, its MIT licence, and the ACLED/UCDP origin — attribution is required.

**Deleted:** `posts/logistic-separation/` **and** `_freeze/posts/logistic-separation/` (round 5,
"delete outright"). Consequences to record in the commit message and the post's status line:
the live URL will **404**, inbound links and bookmarks break, and the RSS GUID disappears. This is a
deliberate, user-approved exception to the repo's "slugs are permanent" rule.

**Unchanged:** `stats.qmd` (the hub needs no edit — it lists by category), `CATEGORIES.md`
(`stats-cases` already exists), theme files, `_quarto.yml`.

---

## 7. Presentation (rounds 4–5)

**Reader:** general data-literate, per round 5 — lead with the finding, keep the modelling in a
collapsible/later section, ~10 minute read, light on maths.

**Charts with annotations by default; tables only where a chart cannot carry the exact values**
(round 4). Planned figures:

1. **Trend caterpillar** — 37 states ordered by trend, with CIs, national trend annotated; the
   shrinkage story made visible by showing no-pooling and partial-pooling estimates together.
2. **Divergence fan** — 2015 and 2025 levels per state, the north-west split annotated directly on
   the plot.
3. **The three "worse" lists** — a set/overlap visual, annotated, not three tables.
4. **Frequency vs lethality scatter** — events against deaths-per-event, Borno and Niger labelled;
   the 0.50 rank correlation annotated.
5. **LGA deadliest-month chart** — 772 LGAs as a dot-and-interval chart, ordered, the top few
   annotated with the actual month and toll.
6. **Seasonality** — deaths by calendar month, equal-year comparison, the 1.22 ratio annotated;
   the flat events line beside it for contrast.

**Interactivity:** `ggiraph` "where it earns it" (round 5) — hover on the caterpillar and the
772-LGA chart; static elsewhere. **No plotly**, and no raw per-row data shipped to the browser
(repo rule on page weight; `posts/weakly-informative-priors` is the worked example of binning
server-side).

**Tables:** only for the M0–M4 / family ΔAIC comparison and the top-N deadliest months.

---

## 8. Reproducibility and compute

- `set.seed()` fixed at the top of `analysis.R`; recorded in the post.
- `glmmTMB` fits are deterministic; the parametric bootstrap needs the seed to be meaningful.
- Fit on 2015–2025, score on 2026; 2026 never appears in a fit.
- `_freeze/` committed once rendered (repo rule 1) — the heavy fits execute once and replay.
- Everything runs through `Rscript`/`quarto render` on R 4.5.2 with `glmmTMB` 1.1.15.2, `mgcv`
  1.9.4, `ggiraph`, `ggplot2`, `performance`, `marginaleffects`, `ggeffects`.

**Render budget: under 2 minutes** (round 5). See the risk below.

---

## 9. Risks and conflicts

1. **The render budget conflicts with the bootstrap.** A parametric bootstrap over 772 LGA groups
   with refits inside a 2-minute render is not realistic. Mitigation, in order: (a) the bootstrap
   runs in `analysis.R` and caches its intervals to `.rds`, so the *render* only reads them — the
   budget then applies to the cached path, and `--no-freeze` is documented as the slow path;
   (b) approximate the bootstrap by simulating replicate panels and recomputing rates without
   refitting; (c) reduce replicate count and state the number. If none of these holds, the budget
   must be renegotiated — this is the one decision the spec cannot satisfy as stated.
2. **State adjacency must be sourced.** `mgcv`'s `bs="mrf"` needs a neighbourhood list for 37
   states. No shapefile is in the repo. Options: hand-code the adjacency (37 rows, verifiable),
   or download a Nigeria admin-1 boundary set. Hand-coding is preferable for a public repo with no
   geo dependencies.
3. **"Unknown" licence on the reserved dataset.** The chosen MIT dataset is unambiguous; the
   `janeodum/acled-nigeria` fallback is not. If actor-level analysis is ever added, the licence
   question returns.
4. **Public repo.** This spec references local machine paths (`ds-general`, `.cmdstan`,
   `AppData/Local/Temp`). Per `CLAUDE.md`, machine maps are deliberately gitignored — so either
   gitignore this file or strip the paths before committing.
5. **Deleting a published slug** breaks links. Approved, but must be stated in the post and the
   commit.
6. **Six-month test set.** CRPS on 2026 has very little power; no strong claims from it.
7. **AIC and non-nested models.** M0–M4 are nested (`pv_events` families differ in likelihood, so
   family comparison is on AIC as a criterion, not a test) — wording must not overclaim.

---

## 10. Open questions, deliberately deferred

1. **Exceedance threshold τ.** Fixed quantile (95th), a policy-meaningful number (e.g. 50 deaths),
   or fitted via GPD with `extRemes`? Default is the 95th-percentile NB predictive; installing
   `extRemes` would make it a proper POT analysis.
2. **Whether to add a population offset.** Needs an external population-by-state table; would
   convert "worse" from per-area to per-capita and would materially change which states look worst.
3. **Whether the geopolitical-zone level is added** on top of `state/lga` (round 2's zone option was
   not chosen; `mgcv` mrf partly covers the same ground).
4. **Whether the deleted separation content returns** as a section (refused in round 5: deleted
   outright) or as a separate `prior-sims` post later.
5. **Whether to run a Bayesian re-fit** with `brms` purely to report posterior rank probabilities —
   the one thing the frequentist route does not give cleanly, and a possible sequel post.

---

## 11. Acceptance criteria

The work is done when:

- [ ] `analysis.R` reproduces every number in the post from the committed CSV, `set.seed()`ed.
- [ ] AIC table for M0–M4 and for Poisson / NB / ZINB / hurdle, with the winner stated.
- [ ] Per-state trends with 95% CIs, and the three "worse" lists compared.
- [ ] The one `mgcv` MRF spatial check reported, whichever way it lands.
- [ ] All four outcomes covered for the deadliest-month question.
- [ ] Argmax, P(rank first) and exceedance all shown, with their disagreements annotated.
- [ ] LightGBM control scored by CRPS on 2026 beside the GLMM, with leakage discipline stated.
- [ ] Calibration checked on 2026 (PIT or coverage), reported honestly.
- [ ] Every caveat in §2 and §9 appears in the post: provisional 2026, ACLED revision, no
      population offset, six-month test set, coverage deepening over time.
- [ ] `logistic-separation` removed with its `_freeze` artifacts; the URL-breakage stated.
- [ ] Render under 2 minutes on the cached path; `_freeze/` committed.
- [ ] No plotly figures carrying raw rows; `ggiraph` only where it earns it.
