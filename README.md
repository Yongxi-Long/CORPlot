
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

This is a basic example which shows you how to solve a common problem:

``` r
library(CORPlot)
## basic example code
PerformLogReg(data=df_MR_CLEAN,
              formula = mRS~group,
              GroupName = "group",
              upper = TRUE)
#>      Label        OR  lower95CI upper95CI
#> 1 mRS >= 1 0.1422306 0.01699793 1.1901179
#> 2 mRS >= 2 0.4863509 0.25511178 0.9271904
#> 3 mRS >= 3 0.4877558 0.32369114 0.7349777
#> 4 mRS >= 4 0.5291186 0.36959102 0.7575036
#> 5 mRS >= 5 0.7012403 0.47701138 1.0308725
#> 6 mRS >= 6 0.9388357 0.61218085 1.4397909

# PerformLogReg(data=df_MR_CLEAN,
#               formula = mRS ~ group+sex,
#               GroupName = "group")
# 
# PerformLogReg(data=df_MR_CLEAN,
#               formula = mRS ~ group+sex,
#               GroupName = "sex")
```
