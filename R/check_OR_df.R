check_OR_df <- function(df)
{
  # must be a data.frame
  if (!is.data.frame(df)) {
    stop("Input must be a data.frame.")
  }

  # must have at least 2 rows
  if (nrow(df) < 2) {
    stop("Input data.frame must have at least two rows.")
  }

  # required columns
  required_cols <- c("Label", "OR", "lowerCI", "upperCI")
  missing <- setdiff(required_cols, names(df))
  if (length(missing) > 0) {
    stop("Input data.frame is missing required columns: ",
         paste(missing, collapse = ", "))
  }

  # Label must be character (convert if needed)
  if (!is.character(df$Label)) {
    df$Label <- as.character(df$Label)
    warning("`Label` column was converted to character.")
  }

  # check for "common OR" label (liberal matching)
  valid_labels <- c("common odds ratio","common or", "cor")  # lowercase reference set
  # normalize labels
  lbl_lower <- tolower(df$Label)
  if (!any(lbl_lower %in% valid_labels)) {
    stop("Input data.frame must contain a row with Label = 'common OR' (accepted forms: 'common OR', 'common or', 'cOR', 'cor').")
  } else
  {
    # standardize the label
    df$Label[lbl_lower %in% valid_labels] <- "common OR"
  }

  # numeric checks
  for (col in c("OR", "lowerCI", "upperCI")) {
    if (!is.numeric(df[[col]])) {
      stop("Column `", col, "` must be numeric.")
    }
    if (any(is.na(df[[col]]))) {
      warning("Column `", col, "` contains NA values.")
    }
  }
  return(df)
}
