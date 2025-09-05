
<!-- README.md is generated from README.Rmd. Please edit that file -->

# CORPlot

<!-- badges: start -->
<!-- badges: end -->

The goal of CORPlot is to create cumulative odds ratio plot to visually
inspect the proportional odds assumption from the proportional odds
model.

## Installation

You can install the development version of CORPlot from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Yongxi-Long/CORPlot")
```

## Example

There are three steps to make a cumulative odds ratio plot, each
corresponds to a function in this package:

- *PerformLogReg*: Perform cumulative logistic regression (i.e., no
  proportionality constraint) and get all binary odds ratios
- *PerformPO*: Perform the proportional odds model and get the common
  odds ratio
- *CORPlot*: Create the cumulative odds ratio plot

Users can directly input to the CORPlot() funtion and this function will
do the first two steps internally. Or users can choose to supplied a
data frame of odds ratios calculated externally and ask CORPlot to make
the plot.

``` r
library(CORPlot)
library(knitr)
#> Warning: package 'knitr' was built under R version 4.3.3

# load the example data of the MR CLEAN trial
data(df_MR_CLEAN)

## use PerforLogReg function to get all binary odds ratios
# We calculate the odds ratio for the group effect, adjusted by sex
# This is done by putting both group and sex in the formula
# and ask for group effect by letting GroupName = "group"
# similarly, if we want the odds ratio of the sex effect, adjusted by group
# we can let GroupName = "sex"

binary_ORs_df <- PerformLogReg(data=df_MR_CLEAN,
              formula = mRS~group+sex,
              GroupName = "group",
              upper = TRUE)
binary_ORs_df |>
  kable(digits = 3, format = "markdown",
        caption = "Binary odds ratios of the 7-point mRS outcome in the MR CLEAN trial") 
```

| Label     |    OR | lower95CI | upper95CI |
|:----------|------:|----------:|----------:|
| mRS \>= 1 | 0.132 |     0.015 |     1.145 |
| mRS \>= 2 | 0.457 |     0.240 |     0.869 |
| mRS \>= 3 | 0.485 |     0.322 |     0.731 |
| mRS \>= 4 | 0.533 |     0.372 |     0.763 |
| mRS \>= 5 | 0.702 |     0.477 |     1.033 |
| mRS \>= 6 | 0.954 |     0.622 |     1.463 |

Binary odds ratios of the 7-point mRS outcome in the MR CLEAN trial
