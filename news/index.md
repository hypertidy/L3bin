# Changelog

## L3bin 0.1.0

First versioned release, adding a version number, documentation
housekeeping and an archived copy of the scheme’s specification.

### Documentation

- The NASA OBPG page “Integerized Sinusoidal Binning Scheme for Level 3
  Data”
  (<https://oceancolor.gsfc.nasa.gov/resources/docs/format/l3bins/>) is
  no longer reliably available. An archived Markdown copy, with its
  figures and the raw MHTML capture, is now included under
  `inst/l3bins/`, recovered from the Wayback Machine capture of
  2026-01-06
  (<https://web.archive.org/web/20260106075308/https://oceancolor.gsfc.nasa.gov/resources/docs/format/l3bins/>).

- The archived page is also hosted on the package website as the article
  “Integerized Sinusoidal Binning Scheme for Level 3 Data”
  (<https://hypertidy.github.io/L3bin/articles/l3bins.html>).

- The package `URL`, the README and the
  [`L3bin()`](https://hypertidy.github.io/L3bin/reference/L3bin.md)
  reference now point to the archived copy rather than the original NASA
  page.

- The README credits the SeaWiFS L3 bin scheme as the inspiration for
  storing per-cell sums and sums of squares on a discrete global grid,
  as explored in mdsumner/trend.sst.

- The README warns that bin numbers are stored as integers, which
  overflow beyond roughly 41000 rows
  ([\#3](https://github.com/hypertidy/L3bin/issues/3)).

### Other changes

- [`bin_from_lonlat()`](https://hypertidy.github.io/L3bin/reference/bin_from_lonlat.md)
  now keeps `lon = 180` in the last bin of its row. It previously
  returned the first bin of the next row, because the clamp at the
  antimeridian seam was commented out. This also affects
  [`crop_bins()`](https://hypertidy.github.io/L3bin/reference/crop_bins.md)
  for extents that reach 180.

- Added a testthat suite covering bin/lonlat round trips, grid
  structure, extents and cropping.

- GitHub Actions workflows updated to current versions.

- The default branch is now `main` (previously `master`).

- Fixed typos in the README and `DESCRIPTION`, and regenerated the
  documentation with roxygen2 8.1.0.

### Functions

The package provides
[`L3bin()`](https://hypertidy.github.io/L3bin/reference/L3bin.md),
[`bin_from_lonlat()`](https://hypertidy.github.io/L3bin/reference/bin_from_lonlat.md),
[`lonlat_from_bin()`](https://hypertidy.github.io/L3bin/reference/lonlat_from_bin.md),
[`extent_from_bin()`](https://hypertidy.github.io/L3bin/reference/extent_from_bin.md),
[`crop_bins()`](https://hypertidy.github.io/L3bin/reference/crop_bins.md)
and
[`row_from_lat()`](https://hypertidy.github.io/L3bin/reference/row_from_lat.md).
These were previously part of sosoc/croc.
