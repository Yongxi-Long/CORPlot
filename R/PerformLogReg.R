#' Perform Cumulative Logistic Regression and Extract Binary Odds Ratios
#'
#' Fits a cumulative logistic regression model for an ordinal outcome using
#' \pkg{VGAM}, and extracts the estimated binary odds ratios and 95% confidence
#' intervals for the specified grouping variable across all possible cutpoints
#'
#' @param data A data frame containing variables in the model
#' @param formula A formula specifying the model, with an ordinal
#' outcome on the left-hand side and one or more predictors
#' on the right-hand side (e.g. \code{mRS ~ group}).
#' @param GroupName Optional character string specifying the name
#' of the grouping (exposure) variable for which odds ratios are
#' to be extracted. If \code{NULL} (default), the first covariate
#' in the formula is used.
#' @param upper Logical; if \code{FALSE} (default), odds ratios
#' correspond to the probability of the outcome being less than
#' or equal to each cut-point. If \code{TRUE}, odds ratios are
#' based on the probability of being greater than or equal to
#' each cut-point.
#' @param confLevel Confidence level; default is 0.95
#'
#' @return A data frame with one row per binary cut-point. Columns are:
#' \describe{
#'   \item{Label}{Text label of the cut-point (e.g. \code{"mRS <= 2"}).}
#'   \item{OR}{Estimated odds ratio for \code{GroupName}.}
#'   \item{lower95CI}{Lower bound of the 95% confidence interval.}
#'   \item{upper95CI}{Upper bound of the 95% confidence interval.}
#' }
#'
#' @details
#' The function uses \code{\link[VGAM]{vglm}} with
#' \code{\link[VGAM]{cumulative}} family to fit an ordinal
#' regression model without the proportional odds assumption
#' (\code{parallel = FALSE}). Confidence intervals are computed
#' using \code{\link[stats]{confint}}; if this fails, confidence
#' intervals are returned as \code{NA}.
#'
#' @examples
#' if (requireNamespace("VGAM", quietly = TRUE)) {
#'   # Simulated data
#'   set.seed(123)
#'   dat <- data.frame(
#'     mRS   = factor(sample(0:3, 100, replace = TRUE), ordered = TRUE),
#'     group = sample(c("A", "B"), 100, replace = TRUE)
#'   )
#'
#'   # Fit and extract odds ratios
#'   PerformLogReg(dat, mRS ~ group, GroupName = "group")
#' }
#'
#' @importFrom stats confint
#' @export
PerformLogReg <- function(data,
                          formula,
                          GroupName=NULL,
                          upper=FALSE,
                          confLevel = 0.95)
{
  #################### Input checks #################
  # check formula
  if (!inherits(formula, "formula")) {
    stop("`formula` must be a valid formula object, e.g. Score ~ Group")
  }
  # check data
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame")
  }
  if(is.null(GroupName))
  {
    warning("GroupName is not supplied, the first covariate name in the formula will be used!")
    GroupName <- all.vars(formula)[2]
  }
  # check GroupName exists in data,
  if (!GroupName %in% names(data)) {
    stop("`GroupName` (", GroupName, ") not found in data")
  }
  # Extract ScoreName and ScoreValues from data for creating
  # cutpoint labels
  ScoreName <- all.vars(formula)[1]
  ScoreValues <- unique(as.numeric(data[[ScoreName]]))

  ################# Model Fitting ##################
  # fit the cumulative logistic regression model
  mod_multinom <- tryCatch(
    VGAM::vglm(formula = formula,
               data = data,
               family = VGAM::cumulative(parallel = FALSE, reverse = upper)),
    error = function(e) {
      stop("Model fitting failed: ", e$message)
    }
  )

  ################# Extract relevant binary odds ratios ################
  # binary ORs for each cut-point
  coefs <- mod_multinom@coefficients
  idx <- grep(GroupName,names(coefs))
  if (length(idx) == 0) {
    stop("No coefficients found matching `GroupName` (", GroupName, ")")
  }
  b_ORs <- exp(coefs[idx])

  # upper and lower CI for binary ORs
  CIs <- tryCatch(
    stats::confint(mod_multinom,level=confLevel),
    error = function(e) {
      warning("Failed to compute confidence intervals: ", e$message)
      NULL
    }
  )
  if (is.null(CIs)) {
    b_ORs_CI <- matrix(NA, nrow = length(idx), ncol = 2)
  } else {
    b_ORs_CI <- exp(CIs[idx, ])
    if(is.null(dim(b_ORs_CI)))
    {
      b_ORs_CI <- matrix(b_ORs_CI,nrow=length(idx),ncol=2)
    }
  }

  ################# Prepare output ################
  # prepare cutpoint label for each binary OR
  symbol <- ifelse(upper," >= "," <= ")
  cutpoints <- (1-upper)*(ScoreValues[-length(ScoreValues)])+upper*ScoreValues[-1]
  cutpoint_labels <- paste0(ScoreName,symbol,cutpoints)
  # prepare the output data frame of binary ORs
  ORs <- data.frame(
    Label    = cutpoint_labels,
    OR       = as.numeric(b_ORs),
    lowerCI = as.numeric(b_ORs_CI[, 1]),
    upperCI = as.numeric(b_ORs_CI[, 2]),
    stringsAsFactors = FALSE
  )
  rownames(ORs) <- NULL
  return(ORs)
}
