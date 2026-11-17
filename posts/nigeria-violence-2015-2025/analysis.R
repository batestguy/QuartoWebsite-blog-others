# analysis.R — every number in the post comes from here.
#
# Sourced by index.qmd in a setup chunk, so the prose and the figures cannot
# drift apart. Deterministic: no bootstrap, no random draws, no seed needed.
#
# Data: data/acled_clean_lga_month.csv, 2015-2026, one row per
# (state, lga, year, month). See data/PROVENANCE.md.

suppressPackageStartupMessages({
  library(glmmTMB)
  library(plotly)
})

comma <- function(x, digits = 0) {
  formatC(x, format = "f", big.mark = ",", digits = digits)
}

raw <- read.csv("data/acled_clean_lga_month.csv", stringsAsFactors = FALSE)
stopifnot(
  nrow(raw) == 106536,
  length(unique(raw$state)) == 37,
  !anyDuplicated(raw[c("state", "lga", "year", "month")])
)

raw$m <- match(raw$month, month.name)
stopifnot(!anyNA(raw$m))

# Fit window: 2015-2025. 2026 is held back for display only.
fit_dat <- raw[raw$year <= 2025, ]
stopifnot(nrow(fit_dat) == 101904)

# ---- Headline totals -------------------------------------------------------
tot <- c(
  events = sum(fit_dat$pv_events),
  deaths = sum(fit_dat$pv_fatalities),
  cells  = nrow(unique(raw[c("state", "lga")])),
  years  = length(unique(fit_dat$year))
)

# ---- State-month panel, the model's grain ---------------------------------
sm <- aggregate(cbind(pv_events, pv_fatalities) ~ state + year + m,
                data = fit_dat, FUN = sum)
sm$t <- sm$year + (sm$m - 0.5) / 12
stopifnot(nrow(sm) == 37 * 132)

# ---- One hierarchical negative binomial, state-varying slopes -------------
# Cached: the fit takes about 100 s, and it does not depend on the prose.
dir.create("cache", showWarnings = FALSE)
cache_file <- "cache/trend-model.rds"
if (file.exists(cache_file) && !nzchar(Sys.getenv("REFIT"))) {
  fit <- readRDS(cache_file)
} else {
  fit <- glmmTMB(
    pv_events ~ t + (1 + t | state),
    family = nbinom2, data = sm,
    control = glmmTMBControl(optCtrl = list(iter.max = 1e5, eval.max = 1e5))
  )
  saveRDS(fit, cache_file)
}

re    <- ranef(fit, condVar = TRUE)$cond$state
b_fix <- fixef(fit)$cond[["t"]]
# attr("condVar") is a 2x2x37 array with no dimnames, in the same group order
# as the rows of the conditional modes: [1,1] intercept, [2,2] slope.
re$se <- sqrt(attr(re, "condVar")[2, 2, ])

trend <- data.frame(
  state = rownames(re),
  slope = b_fix + re$t,
  se    = re$se,
  stringsAsFactors = FALSE
)
trend$pct  <- 100 * (exp(trend$slope) - 1)
trend$low  <- 100 * (exp(trend$slope - 1.96 * trend$se) - 1)
trend$high <- 100 * (exp(trend$slope + 1.96 * trend$se) - 1)

national_pct <- 100 * (exp(b_fix) - 1)
trend_sd     <- sd(trend$pct)

# Three rules, three lists. The post reports the lists, not a verdict.
trend$worse  <- trend$low > 0
trend$hb     <- trend$low > 0 & trend$pct >= 10
trend$q      <- p.adjust(2 * pnorm(-abs(trend$slope / trend$se)), "BH")
trend$fdr    <- trend$q < 0.05

n_worse <- sum(trend$worse)
n_hb    <- sum(trend$hb)
n_fdr   <- sum(trend$fdr)
n_flat  <- sum(!trend$worse)

# ---- Level, for "already worst" -------------------------------------------
last_year <- max(fit_dat$year)
lev <- aggregate(cbind(pv_events, pv_fatalities) ~ state, data = fit_dat, FUN = sum)
names(lev)[2:3] <- c("events15_25", "deaths15_25")
worst <- lev[which.max(lev$deaths15_25), ]
trend$deaths15_25 <- lev$deaths15_25[match(trend$state, lev$state)]

# The claim the post tests: growth and level are different rankings.
rho_level <- cor(trend$pct, trend$deaths15_25, method = "spearman")
fast_top  <- head(trend[order(-trend$pct), ], 6)
borno     <- trend[trend$state == "Borno", ]

# ---- Frequency against lethality ------------------------------------------
lev$per_event <- lev$deaths15_25 / lev$events15_25
rho_fe <- cor(lev$events15_25, lev$per_event, method = "spearman")
rho_fd <- cor(lev$events15_25, lev$deaths15_25, method = "spearman")

# ---- Deadliest state-months, 2019-2025 ------------------------------------
# 2026 is Jan-Jun only and still being revised, so it is not in this ranking.
recent <- raw[raw$year >= 2019 & raw$year <= 2025, ]
mon <- aggregate(cbind(pv_events, pv_fatalities) ~ state + year + m,
                 data = recent, FUN = sum)
mon$label <- sprintf("%s %s %d", mon$state, month.abb[mon$m], mon$year)
top12 <- head(mon[order(-mon$pv_fatalities), ], 12)
top12$fat_share <- 100 * top12$pv_fatalities / sum(top12$pv_fatalities)
n_borno_top <- sum(top12$state == "Borno")
borno_share <- sum(top12$pv_fatalities[top12$state == "Borno"]) /
               sum(top12$pv_fatalities)
outlier <- top12[top12$state != "Borno", ][1, ]
borno_tot <- sum(mon$pv_fatalities[mon$state == "Borno"])
nat_tot   <- sum(mon$pv_fatalities)

# ---- The single deadliest LGA-month ---------------------------------------
lga <- aggregate(cbind(pv_events, pv_fatalities) ~ state + lga + year + m,
                 data = recent, FUN = sum)
lga_top <- head(lga[order(-lga$pv_fatalities), ], 1)

# ---- Seasonality, equal years ---------------------------------------------
seas <- aggregate(cbind(pv_events, pv_fatalities) ~ m + year,
                  data = recent, FUN = sum)
n_years <- length(unique(seas$year))
seas_m <- aggregate(cbind(pv_events, pv_fatalities) ~ m, data = seas, FUN = sum)
seas_m$events_pm  <- seas_m$pv_events / n_years
seas_m$deaths_pm  <- seas_m$pv_fatalities / n_years
h1 <- mean(seas_m$deaths_pm[seas_m$m %in% 1:6])
h2 <- mean(seas_m$deaths_pm[seas_m$m %in% 7:10])
season_ratio <- h1 / h2
ev_ratio <- mean(seas_m$events_pm[seas_m$m %in% 1:6]) /
            mean(seas_m$events_pm[seas_m$m %in% 7:10])

# Per state, the deadliest calendar month of the year (2019-2025 totals).
by_state_m <- aggregate(pv_fatalities ~ state + m, data = recent, FUN = sum)
peak_month <- do.call(rbind, lapply(split(by_state_m, by_state_m$state),
  function(x) x[which.max(x$pv_fatalities), ]))
spring_states <- sum(peak_month$m <= 5)
