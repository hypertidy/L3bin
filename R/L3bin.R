#' @importFrom utils tail
.snapout1 <- function(x, min, max) {
  if (x[1] > min) x <- c(x[1] - 1, x)
  if (tail(x, 1L) < max) x <- c(x, tail(x, 1) + 1)
  x
}
# duplicated from sosoc/croc
.seqfl <- function(fl) seq(fl[1], fl[length(fl)])

#' Crop L3 init object with an extent
#'
#' Crop L3 list, returns bins that fall within the extent.
#'
#' duplicated from sosoc/croc where it is called crop_init
#' @param x L3bin object
#' @param extent vector of 'c(xmin, xmax, ymin, ymax)'
#' @return  integer vector of bins
#' @examples
#' init <- L3bin(24)
#' crop_bins(init, c(100, 110, -50, -45))
#' @export
crop_bins <- function(x, extent) {
  ext <- extent
  nrows <- length(x$basebin)
  ilat <- which(x$latbin >= ext[3L] & x$latbin <= ext[4L] )
  ilat <- .snapout1(ilat, 1L, nrows)

  basebin <- x$basebin[ilat]
  latbin <- x$latbin[ilat]
  listofbins <- vector("list", length(basebin))
  for (i in seq_along(basebin)) {
    firstbin <- bin_from_lonlat(ext[1L], latbin[i], nrows)
    lastbin <- bin_from_lonlat(ext[2L], latbin[i], nrows)
    firstlast <- .snapout1(c(firstbin, lastbin), basebin[i], basebin[+1] - 1)
    listofbins[[i]] <- .seqfl(firstlast)
  }

  listofbins <- unlist(listofbins)
  listofbins
}


#' Latitude to row
#'
#' Originally from sosoc/croc where it is called .lat2row.
#' @param lat latitude
#' @param NUMROWS number of rows in the grid
#'
#' @export
#' @examples
#' row_from_lat(-42, 1024)
row_from_lat <- function(lat, NUMROWS) {
  row <- as.integer((90 + lat) * NUMROWS/180.0)
  row[row >= NUMROWS] <- NUMROWS - 1;
  row + 1
}


#' Generate bin number from longitude latitude.
#'
#' Bin number from longitude and latitude for a given grid with NUMROWS unique latitudes.
#'
#' Originally from sosoc/croc where it is called lonlat2bin
#' @param lon longitude
#' @param lat latitude
#' @param NUMROWS number of rows
#' @export
#' @examples
#' bin_from_lonlat(147, -42, 1024)
bin_from_lonlat <- function(lon, lat, NUMROWS) {
  ibin <- L3bin(NUMROWS)
  row <- row_from_lat(lat, NUMROWS)
  col <- (lon + 180) * ibin$numbin[row] / 360
  ##col[col >= ibin$numbin[row]] <- ibin$numbin[row] - 1
  as.integer(ibin$basebin[row] + col)
}


' Initialize values for a particular binning
#'
#' Set up the basic values for the bin scheme for given number of rows.
#'
#' Originally from sosoc/croc where it is called initbin
#' @param NUMROWS relevant number of L3 bin rows
#' @export
#' @references https://oceancolor.gsfc.nasa.gov/docs/format/l3bins/
#' @examples
#' L3bin(1024)
L3bin <- function(NUMROWS = 2160) {
  ## TODO options for lon-lat sub-sets
  latbin <- (((seq(NUMROWS) - 1) + 0.5) * 180 / NUMROWS ) - 90
  ## this will overflow at 2^31-1
  #numbin <- as.integer(2 * NUMROWS * cos(latbin * pi/180) + 0.5)
  numbin <- trunc(2 * NUMROWS * cos(latbin * pi/180) + 0.5)
  basebin <- cumsum(c(1L, numbin[-length(numbin)]))
  totbins = basebin[NUMROWS] + numbin[NUMROWS] - 1
  list(latbin = latbin, numbin = numbin, basebin = basebin, totbins = totbins)
}
