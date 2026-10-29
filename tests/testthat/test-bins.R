test_that("L3bin grid has the expected structure", {
  nr <- 12
  g <- L3bin(nr)
  expect_equal(g$NUMROWS, nr)
  expect_length(g$latbin, nr)
  expect_length(g$numbin, nr)
  # rows are symmetric about the equator
  expect_equal(g$numbin, rev(g$numbin))
  expect_equal(g$latbin, -rev(g$latbin))
  # bin numbering is contiguous and 1-based
  expect_equal(g$basebin[1], 1)
  expect_equal(diff(g$basebin), g$numbin[-nr])
  expect_equal(g$totbins, sum(g$numbin))
})

test_that("known total bin count is reproduced", {
  # 2160 rows is the base SeaWiFS resolution
  expect_equal(L3bin(2160)$totbins, 5940422)
})

test_that("row_from_lat is 1-based from the south and clamps at the pole", {
  expect_equal(row_from_lat(c(-90, 90), 12), c(1, 12))
  expect_equal(row_from_lat(c(-0.1, 0.1), 12), c(6, 7))
})

test_that("bin centres round trip through bin_from_lonlat", {
  for (nr in c(6, 12, 24, 96)) {
    tot <- L3bin(nr)$totbins
    bins <- seq_len(tot)
    ll <- lonlat_from_bin(bins, nr)
    expect_equal(dim(ll), c(tot, 2L))
    expect_equal(bin_from_lonlat(ll[, 1], ll[, 2], nr), bins)
  }
})

test_that("bin_from_lonlat returns valid bins, including at the poles", {
  nr <- 24
  tot <- L3bin(nr)$totbins
  lon <- c(-179.9, 0, 147, 179.9, -179.9, -179.9)
  lat <- c(0, 0, -42, 10, -90, 90)
  b <- bin_from_lonlat(lon, lat, nr)
  expect_true(all(b >= 1 & b <= tot))
  # western edge of the first and last rows
  expect_equal(b[5], 1)
  expect_equal(b[6], L3bin(nr)$basebin[nr])
})

test_that("extent_from_bin bounds contain the bin centre", {
  nr <- 12
  bins <- seq_len(L3bin(nr)$totbins)
  ex <- extent_from_bin(bins, nr)
  ll <- lonlat_from_bin(bins, nr)
  expect_equal(colnames(ex), c("xmin", "xmax", "ymin", "ymax"))
  expect_true(all(ex[, "xmin"] < ll[, 1] & ll[, 1] < ex[, "xmax"]))
  expect_true(all(ex[, "ymin"] < ll[, 2] & ll[, 2] < ex[, "ymax"]))
  # extents tile the globe in latitude
  expect_equal(min(ex[, "ymin"]), -90)
  expect_equal(max(ex[, "ymax"]), 90)
})

test_that("crop_bins returns bins covering the extent", {
  nr <- 24
  g <- L3bin(nr)
  ext <- c(100, 110, -50, -45)
  cb <- crop_bins(g, ext)
  expect_true(all(cb >= 1 & cb <= g$totbins))
  expect_false(anyDuplicated(cb) > 0)
  # a point inside the extent falls in a returned bin
  expect_true(bin_from_lonlat(105, -47, nr) %in% cb)
  expect_error(crop_bins(g, c(110, 100, -50, -45)), "invalid extent")
})

test_that("lon = 180 stays in the last bin of its row", {
  for (nr in c(12, 96)) {
    g <- L3bin(nr)
    lat <- g$latbin
    expect_equal(bin_from_lonlat(rep(180, nr), lat, nr), g$basebin + g$numbin - 1)
    expect_equal(row_from_lat(lat, nr), seq_len(nr))
    # and the western seam is the first bin of the row
    expect_equal(bin_from_lonlat(rep(-180, nr), lat, nr), g$basebin)
  }
  # all returned bins are valid for a lon sweep including both seams
  tot <- L3bin(24)$totbins
  b <- bin_from_lonlat(rep(c(-180, 0, 180), each = 5), rep(c(-90, -45, 0, 45, 90), 3), 24)
  expect_true(all(b >= 1 & b <= tot))
})
