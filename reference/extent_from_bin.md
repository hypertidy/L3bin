# Calculate bin boundaries from bin number

Calculate bin boundaries from bin number

## Usage

``` r
extent_from_bin(bin, NUMROWS)
```

## Arguments

- bin:

  bin number

- NUMROWS:

  relevant number of L3 bin rows

## Value

matrix of extent columns xmin,xmax,ymin,ymax -

## Details

Bin boundaries are the xmin, xmax, ymin, ymax edge of each bin - compare
to the output of ` `lonlat_from_bin\` which returns only the centre of
each bin. This function previously lived in sosoc/croc where it is
called bin2bounds

## Examples

``` r
bins <- L3bin(NUMROWS = 12)
ex <- extent_from_bin(1:bins$totbins, 12)
plot(range(ex[,1:2]), range(ex[,3:4]), type = "n", asp = 1)
points(lonlat_from_bin(1:bins$totbins, 12), pch = "+", cex = .8)
rect(ex[,1], ex[,3], ex[,2], ex[,4])
```
