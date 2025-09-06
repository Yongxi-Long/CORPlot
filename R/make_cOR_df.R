make_cOR_df <- function(OR_df) {
  # validate first
  OR_df <- check_OR_df(OR_df)

  # find the common OR row (already standardized by check_OR_dataframe)
  idx <- which(OR_df$Label == "common OR")
  if (length(idx) != 1) {
    stop("`OR_df` must contain exactly one row with Label = 'common OR'.")
  }

  # extract the common OR values
  common_vals <- OR_df[idx, c("OR", "lowerCI", "upperCI")]

  # replicate across all rows
  common_df <- OR_df
  common_df[, c("OR", "lowerCI", "upperCI")] <-
    lapply(common_vals, function(x) rep(x, nrow(OR_df)))
  common_df$type <- "Under PO assumption"
  return(common_df)
}
