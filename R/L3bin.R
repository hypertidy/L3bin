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
#' This function previously lived in sosoc/croc where it is called crop_init
#' @param x L3bin object
#' @param extent vector of 'c(xmin, xmax, ymin, ymax)'
#' @return  integer vector of bins
#' @examples
#' init <- L3bin(24)
#' crop_bins(init, c(100, 110, -50, -45))
#' @export
crop_bins <- function(x, extent) {
  if (any(diff(extent)[c(1, 3)] <= 0)) stop("invalid extent, must be c(xmin, xmax, ymin, ymax)")
  ext <- extent
  nrows <- x$NUMROWS
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
#'
#' Row is 1-based, and starts at the southern-most row.
#'
#' This function previously lived in sosoc/croc where it is called .lat2row.
#'
#' @param lat latitude
#' @param NUMROWS number of rows in the grid
#'
#' @export
#' @examples
#' row_from_lat(-42, 1024)
#' row_from_lat(c(-90, 0, 90), 1024)
row_from_lat <- function(lat, NUMROWS) {
  row <- as.integer((90 + lat) * NUMROWS/180.0)
  row[row >= NUMROWS] <- NUMROWS - 1;
  row + 1
}


#' Generate bin number from longitude latitude.
#'
#' Bin number from longitude and latitude for a given grid with NUMROWS unique latitudes.
#'
#' This function previously lived in sosoc/croc where it is called lonlat2bin
#' @param lon longitude
#' @param lat latitude
#' @param NUMROWS number of rows in the grid
#'
#' @return integer vector of bin number
#' @export
#' @examples
#' bin_from_lonlat(147, -42, 1024)
#' bin_from_lonlat(c(0, 0, 0), c(-90, 0, 90), 1024)
bin_from_lonlat <- function(lon, lat, NUMROWS) {
  ibin <- L3bin(NUMROWS)
  row <- row_from_lat(lat, NUMROWS)
  col <- (lon + 180) * ibin$numbin[row] / 360
  ##col[col >= ibin$numbin[row]] <- ibin$numbin[row] - 1
  as.integer(ibin$basebin[row] + col)
}

#' Longitude and latitude from bin number.
#'
#' Generate longitude and latitude coordinates from bin number.
#'
#' This function previously lived in  sosoc/croc where it is called bin2lonlat
#' @param bins bin number
#' @param NUMROWS number of rows in this grid
#' @return matrix of longitude, latitude the centre coordinate of the bin
#' @export
#' @examples
#' lonlat_from_bin(c(1, 184), 12)
lonlat_from_bin <- function(bins, NUMROWS) {
  row <- seq_len(NUMROWS) - 1
  latbin = ((row + 0.5)*180.0/NUMROWS) - 90.0;
  numbin <- as.integer((2*NUMROWS*cos(latbin*pi/180.0) + 0.5))
  basebin <- c(1L, utils::head(cumsum(numbin) + 1L, -1L))
  totbins <- utils::tail(basebin, 1) + utils::tail(numbin, 1) - 1
  index <- findInterval(bins, basebin)
  lat <- latbin[index]
  lon <- 360.0*(bins - basebin[index] + 0.5)/numbin[index] - 180.0;
  cbind(lon, lat)
}

' Initialize values for a particular binning
#'
#' Set up the basic values for the bin scheme for given number of rows.
#'
#' This function previously lived in sosoc/croc where it is called initbin
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
  if (totbins > (2^31-1)) {
    message("maximum NUMROWS is approximately 41000, the grid cell logic may overflow - see github issue #3")
  }
  list(NUMROWS = NUMROWS, latbin = latbin,
       numbin = numbin, basebin = basebin, totbins = totbins)
}


#' Calculate bin boundaries from bin number
#'
#' Calculate bin boundaries from bin number
#'
#' Bin boundaries are the xmin, xmax, ymin, ymax edge of each bin  - compare to the output of `
#' `lonlat_from_bin` which returns only the centre of each bin.
#' This function previously lived in sosoc/croc where it is called bin2bounds
#' @param bin bin number
#' @param NUMROWS relevant number of L3 bin rows
#' @return matrix of extent columns xmin,xmax,ymin,ymax -
#' @export
#' @examples
#' bins <- L3bin(NUMROWS = 12)
#' ex <- extent_from_bin(1:bins$totbins, 12)
#' plot(range(ex[,1:2]), range(ex[,3:4]), type = "n", asp = 1)
#' points(lonlat_from_bin(1:bins$totbins, 12), pch = "+", cex = .8)
#' rect(ex[,1], ex[,3], ex[,2], ex[,4])
extent_from_bin <- function(bin, NUMROWS) {
  row = NUMROWS - 1;
  latbin <- (((seq(NUMROWS) - 1) + 0.5) * 180 / NUMROWS ) - 90
  numbin <- as.integer(2 * NUMROWS * cos(latbin * pi/180) + 0.5)
  basebin <- cumsum(c(1L, numbin[-length(numbin)]))
  fint <- findInterval(bin, basebin)
  north <- latbin[fint] + 90.0/NUMROWS
  south <- latbin[fint] - 90.0/NUMROWS
  ##*north = latbin[row] + 90.0/NUMROWS;
  ##*south = latbin[row] - 90.0/NUMROWS;
  lon = 360.0*(bin - basebin[fint] + 0.5)/numbin[fint] - 180.0;
  west = lon - 180.0/numbin[fint];
  east = lon + 180.0/numbin[fint];
  cbind(xmin = west, xmax =   east, ymin = south,  ymax = north)
}
