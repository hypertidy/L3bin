# Crop L3 init object with an extent

Crop L3 list, returns bins that fall within the extent.

## Usage

``` r
crop_bins(x, extent)
```

## Arguments

- x:

  L3bin object

- extent:

  vector of 'c(xmin, xmax, ymin, ymax)'

## Value

integer vector of bins

## Details

This function previously lived in sosoc/croc where it is called
crop_init

## Examples

``` r
init <- L3bin(24)
crop_bins(init, c(100, 110, -50, -45))
#> [1]  69  70  99 100 101 135 136 137
```
