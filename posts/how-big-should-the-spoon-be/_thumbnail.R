# Builds thumbnail.png, the listing image for this post.
#
# Run:  Rscript posts/how-big-should-the-spoon-be/_thumbnail.R
#
# The leading underscore keeps Quarto's renderer out of this file. It is not
# part of the post; the post's own figure is plotly and interactive, and a
# listing thumbnail has to be a static file.
#
# The country construction below is DUPLICATED from the naijasim chunk in
# index.qmd rather than shared, because a chunk in a frozen post cannot be
# called from outside it. The stopifnot at the end is what makes the duplication
# safe: if this file ever drifts from the post, it fails loudly instead of
# quietly drawing a different country.
#
# Designed to be read at about 200px wide, so it carries no text and no axis
# labels. At that size the shape is the whole message: two curves sitting on the
# truth, one broad and one narrow, and two more sitting together a long way from
# it. The broad curve on the truth is 500 interviews drawn right; the narrowest
# curve of all is 40,000 drawn wrong.

set.seed(20260817)

phone_share <- 0.31
anap_n      <- 2000
elrufai_n   <- 40000
win_n       <- 500      # the rung the post's argument turns on

sim_party <- c("Green", "Blue", "Red", "Yellow")
sim_zone  <- c("North West", "North East", "North Central",
               "South West", "South East", "South South")
sim_reg_z <- c(21, 12, 15, 18, 9, 15) * 1e6
names(sim_reg_z) <- sim_zone
sim_target <- c(Green = 0.30, Blue = 0.38, Red = 0.24, Yellow = 0.08)

sim_zs <- rbind(
  c(0.08, 0.50, 0.36, 0.06),
  c(0.10, 0.52, 0.32, 0.06),
  c(NA,   NA,   NA,   NA  ),
  c(0.34, 0.34, 0.22, 0.10),
  c(0.72, 0.12, 0.08, 0.08),
  c(0.48, 0.26, 0.16, 0.10)
)
dimnames(sim_zs) <- list(sim_zone, sim_party)
i_nc <- match("North Central", sim_zone)
sim_zs[i_nc, ] <- (sum(sim_reg_z) * sim_target -
                   colSums(sim_zs[-i_nc, ] * sim_reg_z[-i_nc])) / sim_reg_z[i_nc]

sim_reach_z <- c(`North West` = 0.160, `North East` = 0.120,
                 `North Central` = 0.300, `South West` = 0.500,
                 `South East` = 0.440, `South South` = NA)[sim_zone]
i_ss <- match("South South", sim_zone)
sim_reach_z[i_ss] <- (phone_share * sum(sim_reg_z) -
                      sum((sim_reg_z * sim_reach_z)[-i_ss])) / sim_reg_z[i_ss]

sim_st <- NULL; sim_reg_s <- numeric(0); sim_szone <- character(0)
for (zn in sim_zone) {
  g <- sim_zs[zn, "Green"]; b <- sim_zs[zn, "Blue"]
  d <- 0.5 * min(g / 1.5, b)
  s_a <- sim_zs[zn, ]; s_a["Green"] <- g + d;       s_a["Blue"] <- b - d
  s_b <- sim_zs[zn, ]; s_b["Green"] <- g - 1.5 * d; s_b["Blue"] <- b + 1.5 * d
  sim_st    <- rbind(sim_st, s_a, s_b)
  sim_reg_s <- c(sim_reg_s, 0.60 * sim_reg_z[[zn]], 0.40 * sim_reg_z[[zn]])
  sim_szone <- c(sim_szone, zn, zn)
}
sim_frame_s <- sim_reg_s * unname(sim_reach_z[sim_szone])

sim_w_true  <- sim_reg_s   / sum(sim_reg_s)
sim_w_frame <- sim_frame_s / sum(sim_frame_s)
sim_truth   <- colSums(sim_st * sim_w_true)

# The post's own guard, repeated: this must be the same country.
stopifnot(
  isTRUE(all.equal(colSums(sim_st * sim_reg_s) / sum(sim_reg_s), sim_target)),
  isTRUE(all.equal(sum(sim_frame_s) / sum(sim_reg_s), phone_share))
)

sim_alloc <- function(n, w) {
  raw <- n * w; a <- floor(raw); k <- n - sum(a)
  if (k > 0) { j <- order(raw - a, decreasing = TRUE)[seq_len(k)]; a[j] <- a[j] + 1 }
  a
}

SIM_REPS <- 4000

sim_run <- function(n, w) {
  a <- sim_alloc(n, w)
  est <- matrix(0, SIM_REPS, 4, dimnames = list(NULL, sim_party))
  for (i in seq_along(a)) {
    if (a[i] == 0) next
    est <- est + w[i] * t(rmultinom(SIM_REPS, a[i], sim_st[i, ])) / a[i]
  }
  est
}

# The ladder's bottom rung is the post's inversion answer, derived here from the
# same quoted inputs so this file's ladder matches the post's exactly. The seed
# reset and the call order below then guarantee these are the same draws.
z        <- qnorm(0.975)
poll_obi <- 21 / (21 + 13 + 10 + 3)
act_obi  <- 6101533 / 24025940
n_cross  <- ceiling(z^2 * poll_obi * (1 - poll_obi) / (poll_obi - act_obi)^2)

set.seed(20260817)
ns_fair  <- c(n_cross, 100, 250, win_n, 1000, anap_n)
ns_phone <- c(anap_n, elrufai_n)
fair  <- lapply(ns_fair,  sim_run, w = sim_w_true)
phone <- lapply(ns_phone, sim_run, w = sim_w_frame)

pal <- c("#0f766e", "#0e7490", "#b45309", "#6d28d9")
ink <- "#57606a"

curves <- list(
  list(x = 100 * fair[[match(win_n, ns_fair)]][,  "Green"], col = pal[1]),
  list(x = 100 * fair[[match(anap_n, ns_fair)]][, "Green"], col = pal[2]),
  list(x = 100 * phone[[match(anap_n, ns_phone)]][,    "Green"], col = pal[3]),
  list(x = 100 * phone[[match(elrufai_n, ns_phone)]][, "Green"], col = pal[4])
)

# Densities up front, so the x-range comes from the curves. The 500-interview
# curve is much the widest and would otherwise be clipped.
dens <- lapply(curves, function(cv) density(cv$x, n = 200))
xlim <- range(unlist(lapply(dens, `[[`, "x")))

png("posts/how-big-should-the-spoon-be/thumbnail.png",
    width = 640, height = 400, res = 96, bg = "white")
par(mar = c(0.6, 0.6, 0.6, 0.6))
plot(NA, xlim = xlim, ylim = c(0, 1.16),
     axes = FALSE, xlab = "", ylab = "")

# The truth, as a dotted rule.
lines(rep(100 * sim_truth[["Green"]], 2), c(0, 1.08), lty = 3, col = ink, lwd = 2)

for (i in seq_along(curves)) {
  d <- dens[[i]]
  y <- d$y / max(d$y)
  polygon(c(d$x[1], d$x, d$x[length(d$x)]), c(0, y, 0),
          col = paste0(curves[[i]]$col, "3D"), border = NA)
  lines(d$x, y, col = curves[[i]]$col, lwd = 3)
}

# A hairline floor, so the curves stand on something.
abline(h = 0, col = "#d7dce1", lwd = 2)
invisible(dev.off())

cat("wrote posts/how-big-should-the-spoon-be/thumbnail.png\n")
