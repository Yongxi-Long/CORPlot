## Code to prepare the dataset df_MR_CLEAN
#' This is based on the MR CLEAN trial, Berkhemer et. al, 2015.
#' To show that this package can also plot adjusted cumulative odds ratios,
#' we artificially create a binary sex variable which can be adjusted for
#' in the model
set.seed(86)
control <- c(0,rep(1, 15), rep(2, 35), rep(3, 44),
             rep(4, 81), rep(5, 32), rep(6, 59)) #267 patients
intervention <- c(rep(0,6),rep(1, 21), rep(2, 49),
                  rep(3, 43), rep(4, 52), rep(5, 13), rep(6, 49)) #233 patients
sex <- rbinom(n=267+233,size=1,prob=0.58)
df_MR_CLEAN <- data.frame(
  mRS= c(intervention,control),
  group = rep(c(1,0),c(233,267)),
  sex = sex
)
usethis::use_data(df_MR_CLEAN, overwrite = TRUE)
