# Builds thumbnail.png, the listing image for this post.
#
# Run from the repo root:
#   Rscript posts/nigeria-violence-2015-2025/_thumbnail.R
#
# The leading underscore keeps Quarto's renderer out of this file.
#
# Unlike the spoon post's thumbnail, this one does not duplicate the model: the
# trend fit is cached by analysis.R, which is a standalone script, so it can be
# sourced directly. That keeps the two from drifting without repeating a
# hundred-second fit. If the cache is missing it is built here, once.
#
# Read at about 200px wide, so it carries no text and no axis labels. The shape
# is the message: thirty-seven intervals ordered by growth, most of them right
# of zero, one of them (Borno) sitting almost on it while being the deadliest.

if (basename(getwd()) != "nigeria-violence-2015-2025") {
  setwd("posts/nigeria-violence-2015-2025")
}

suppressPackageStartupMessages(source("analysis.R"))
stopifnot(nrow(trend) == 37)

ord <- order(trend$pct)
tr  <- trend[ord, ]
y   <- seq_len(nrow(tr))

col_of <- function(s) {
  if (s == "Borno") "#b45309" else if (tr$worse[match(s, tr$state)]) "#0f766e" else "#9aa4b2"
}

png("thumbnail.png", width = 640, height = 400, res = 96, bg = "white")
par(mar = c(0.5, 0.5, 0.5, 0.5))
plot(NA, xlim = range(c(tr$low, tr$high, 0)) + c(-2, 6),
     ylim = c(0.5, nrow(tr) + 0.5), axes = FALSE, xlab = "", ylab = "")

# Zero, as a hairline: the line a state has to cross to count as worse.
abline(v = 0, col = "#d7dce1", lwd = 2)

# The country's rate, dotted, the reference every interval is read against.
abline(v = national_pct, col = "#57606a", lty = 3, lwd = 2)

for (i in y) {
  segments(tr$low[i], i, tr$high[i], i, col = col_of(tr$state[i]), lwd = 2)
  points(tr$pct[i], i, pch = 19, cex = 0.7, col = col_of(tr$state[i]))
}

invisible(dev.off())
cat("wrote", file.path(getwd(), "thumbnail.png"), "\n")
