# Longitude and latitude from bin number.

Generate longitude and latitude coordinates from bin number.

## Usage

``` r
lonlat_from_bin(bins, NUMROWS)
```

## Arguments

- bins:

  bin number

- NUMROWS:

  number of rows in this grid

## Value

matrix of longitude, latitude the centre coordinate of the bin

## Details

This function previously lived in sosoc/croc where it is called
bin2lonlat

## Examples

``` r
lonlat_from_bin(c(1, 184), 12)
#>       lon   lat
#> [1,] -120 -82.5
#> [2,]  120  82.5
```
