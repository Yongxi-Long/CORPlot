#' Perform Proportional Odds Model and Extract the Common Odds Ratio
#'
#' Fits a proportional odds model for an ordinal outcome using
#' \pkg{VGAM}, and extracts the estimated common odds ratio and its 95% confidence
#' intervals for the specified grouping variable
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
#' @return A data frame with one row. Columns are:
#' \describe{
#'   \item{Label}{common OR}
#'   \item{OR}{Estimated common odds ratio for \code{GroupName}.}
#'   \item{lower95CI}{Lower bound of the 95% confidence interval.}
#'   \item{upper95CI}{Upper bound of the 95% confidence interval.}
#' }
#'
#' @details
#' The function uses \code{\link[VGAM]{vglm}} with
#' \code{\link[VGAM]{cumulative}} family to fit an ordinal
#' regression model with the proportional odds assumption
#' (\code{parallel = TRUE}). Confidence intervals are computed
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
#'   # Fit and extract the common odds ratio
#'   PerformPO(dat, mRS ~ group, GroupName = "group")
#' }
#' @importFrom stats confint
#' @export
PerformPO <- function(
    data,
    formula,
    GroupName = NULL,
    upper = FALSE,
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

  ################# Model Fitting ##################
  # fit the multinomial regression model
  mod_po <- tryCatch(
    VGAM::vglm(formula = formula,
               data = data,
               family = VGAM::cumulative(parallel = TRUE, reverse = upper)),
    error = function(e) {
      stop("Model fitting failed: ", e$message)
    }
  )

  ################# Extract common odds ratio ################
  coefs <- mod_po@coefficients
  idx <- grep(GroupName,names(coefs))
  if (length(idx) == 0) {
    stop("No coefficients found matching `GroupName` (", GroupName, ")")
  }
  cOR <- exp(coefs[idx])

  # upper and lower CI for the common odds ratio
  CIs <- tryCatch(
    stats::confint(mod_po,level = confLevel),
    error = function(e) {
      warning("Failed to compute confidence intervals: ", e$message)
      NULL
    }
  )
  if (is.null(CIs)) {
    cOR_CI <- matrix(NA, nrow = length(idx), ncol = 2)
  } else {
    cOR_CI <- exp(CIs[idx, ])
  }

  ################# Prepare output ################
  # prepare the output data frame of common odds ratio
  out <- data.frame(
    Label    = "common OR",
    OR       = cOR,
    lowerCI = cOR_CI[1],
    upperCI = cOR_CI[2],
    stringsAsFactors = FALSE
  )
  rownames(out) <- NULL
  return(out)
}
