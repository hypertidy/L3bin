# Latitude to row

Row is 1-based, and starts at the southern-most row.

## Usage

``` r
row_from_lat(lat, NUMROWS)
```

## Arguments

- lat:

  latitude

- NUMROWS:

  number of rows in the grid

## Details

This function previously lived in sosoc/croc where it is called
.lat2row.

## Examples

``` r
row_from_lat(-42, 1024)
#> [1] 274
row_from_lat(c(-90, 0, 90), 1024)
#> [1]    1  513 1024
```
