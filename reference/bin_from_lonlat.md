# Generate bin number from longitude latitude.

Bin number from longitude and latitude for a given grid with NUMROWS
unique latitudes.

## Usage

``` r
bin_from_lonlat(lon, lat, NUMROWS)
```

## Arguments

- lon:

  longitude

- lat:

  latitude

- NUMROWS:

  number of rows in the grid

## Value

integer vector of bin number

## Details

This function previously lived in sosoc/croc where it is called
lonlat2bin

## Examples

``` r
bin_from_lonlat(147, -42, 1024)
#> [1] 222154
bin_from_lonlat(c(0, 0, 0), c(-90, 0, 90), 1024)
#> [1]       2  668573 1335095
```
