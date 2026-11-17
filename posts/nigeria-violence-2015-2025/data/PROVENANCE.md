# Provenance

`acled_clean_lga_month.csv` is a filtered copy of `acled_cleaned.csv` from the Kaggle dataset
[`justtryit01/nigerian-insecurity-analysis-1997-2026`](https://www.kaggle.com/datasets/justtryit01/nigerian-insecurity-analysis-1997-2026),
published under the MIT licence, updated 2026-08-20.

That dataset is itself compiled from **ACLED** (1997–2026) and **UCDP** (1990–2024), distributed via
HDX. ACLED's own terms apply to the underlying event records; the MIT licence covers the Kaggle
compilation.

## The filter

Kept rows with `year >= 2015`, all months, all states and LGAs. Original file: 273,288 rows,
1997–2026. This copy: 106,536 rows, January 2015 to June 2026, balanced (772 state-LGA cells × 138
months).

Columns are unchanged: `state, lga, month, year, pv_events, pv_fatalities, ct_events, ct_fatalities`.
`pv_*` is all political violence; `ct_*` is the civilian-targeting subset, and is contained in `pv_*`
in every row.

## Checks that hold on this copy

- 106,536 rows, no duplicates on `(state, lga, year, month)`.
- 37 states, 772 distinct `(state, lga)` cells, 765 distinct LGA names (seven names repeat across
  states, so the pair is the key).
- No nulls, no negative counts.
- 29,300 events and 94,586 deaths in 2015–2025.
- 84.8 per cent of rows record no events.

`analysis.R` asserts the row count and the cell/state counts before it fits anything, so a swapped or
truncated file fails the render instead of quietly changing the numbers.

## Re-downloading

The Kaggle download endpoint serves the archive without authentication:

```
curl -L -o acled.zip "https://www.kaggle.com/api/v1/datasets/download/justtryit01/nigerian-insecurity-analysis-1997-2026"
```

then keep `year >= 2015` from `acled_cleaned.csv`. Re-downloading will not reproduce the numbers in
the post exactly if Kaggle has updated the file, which is why the filtered copy is committed.
