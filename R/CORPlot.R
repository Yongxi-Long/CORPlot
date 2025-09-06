#' Create Cumulative Odds Ratio Plot
#'
#' This function produces a cumulative odds ratio (COR) plot for an ordinal outcome.
#' Users can either provide a dataset with a formula and grouping variable so that
#' odds ratios are estimated internally, or supply a pre-computed data frame of
#' odds ratios directly.
#'
#' @param data A data frame containing the outcome and covariate(s).
#' Required if \code{OR_df} is not supplied
#' @param formula A model formula specifying the ordinal outcome on the left-hand side
#' and the grouping variable (or covariates) on the right-hand side
#' (e.g., \code{mRS ~ group}). Required if \code{OR_df} is not supplied.
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
#' @param OR_df Optional data frame of externally computed odds ratios. Must contain
#' at least the following columns:
#'   \itemize{
#'     \item \code{Label} (character or factor): cut-point labels, with one row labeled
#'       "common OR" (case-insensitive).
#'     \item \code{OR} (numeric): odds ratio estimates.
#'     \item \code{lowerCI} (numeric): lower confidence interval bound.
#'     \item \code{upperCI} (numeric): upper confidence interval bound.
#'   }
#'   If supplied, the arguments \code{data}, \code{formula}, and \code{GroupName}
#'   are ignored.
#'
#' @return A list with two elements:
#' \itemize{
#'   \item \code{ORs}: A data frame of odds ratios used for plotting.
#'   \item \code{plot}: A \code{ggplot2} object displaying the cumulative odds ratio plot.
#'   }
#'
#' @details
#' If \code{OR_df} is not supplied, the function internally fits two models:
#' a multinomial regression via \code{PerformLogReg} to estimate binary odds ratios for each cutpoint,
#' and a proportional odds model via \code{PerformPO} to estimate the common odds ratio.
#' These are combined into a single data frame and visualized.
#'
#' @examples
#' # Use internal model fitting
#' data(df_MR_CLEAN)
#' res <- CORPlot(
#' data = df_MR_CLEAN,
#' formula = mRS ~ group,
#' GroupName = "group",
#' confLevel = 0.90
#' )
#' res$`Cumulative Odds Ratio Plot` # show the plot
#' # Use external OR data.frame
#' OR_df <- data.frame(
#'   Label   = c("score<=1", "score<=2", "common OR"),
#'   OR      = c(1.2, 1.5, 1.3),
#'   lowerCI = c(0.9, 1.1, 1.0),
#'   upperCI = c(1.6, 2.0, 1.7)
#' )
#' res2 <- CORPlot(OR_df = OR_df)
#' res2$`Cumulative Odds Ratio Plot`
#' @import ggplot2
#' @import knitr
#' @export
CORPlot <- function(data = NULL,
                    formula = NULL,
                    GroupName = NULL,
                    upper = FALSE,
                    confLevel = 0.95,
                    OR_df=NULL)
{
  # --- Input handling ---
  if (!is.null(OR_df) && (!is.null(data) || !is.null(formula) || !is.null(GroupName))) {
    stop("Please provide either `OR_df` or (`data` + `formula` + `GroupName`), but not both.")
  }

  if(is.null(OR_df))
  {
    if (is.null(data) || is.null(formula) || is.null(GroupName)) {
      stop("When `OR_df` is not supplied, you must provide `data`, `formula`, and `GroupName`.")
    }
    binary_ORs_df <- PerformLogReg(
      data = data,
      formula = formula,
      GroupName = GroupName,
      upper = upper,
      confLevel = confLevel
    )
    cOR_df <- PerformPO(
      data = data,
      formula = formula,
      GroupName = GroupName,
      upper = upper,
      confLevel = confLevel
    )
    OR_df <- rbind(binary_ORs_df,cOR_df)
  } else
  {
    OR_df <- check_OR_df(OR_df)
  }
  OR_df$type <- "Observed"

  # prepare the data.frame for plotting
  # add extra rows under PO assumption
  commonOR_df <- make_cOR_df(OR_df)
  plot_df <- rbind(OR_df,commonOR_df)

  # get range for the y-axis
  plot_range <- c(0.95*min(plot_df$lowerCI,na.rm = TRUE),
             1.05*max(plot_df$upperCI,na.rm = TRUE))
  # label for confidence level
  conf_label <- paste0(100*confLevel,"% CI")

  p <- ggplot()+
    geom_pointrange(
      data = subset(plot_df, type == "Observed" & Label != "common OR"),
      aes(x = .data$Label, y = .data$OR, ymin = .data$lowerCI, ymax = .data$upperCI,
          color = .data$type, linetype = .data$type),
      linewidth = 0.9, size = 0.5)+
    geom_pointrange(
      data = subset(plot_df, type == "Under PO assumption" & Label != "common OR"),
      aes(x = .data$Label, y = .data$OR, ymin = .data$lowerCI, ymax = .data$upperCI,
          color = .data$type, linetype = .data$type),
      position = position_nudge(x = -0.1),   # shifts it below
      linewidth = 0.9, size = 0.5)+
    geom_pointrange(data=subset(plot_df,Label == "common OR" & type == "Under PO assumption"),
                    aes(x=.data$Label, y=.data$OR, ymin=.data$lowerCI, ymax=.data$upperCI),linewidth=0.9,
                    size=0.5,color="coral")+
    geom_hline(yintercept=1, lty=2,color="coral",linewidth=0.8) +
    coord_flip()+
    scale_y_continuous(trans = "log2",limits = plot_range)+
    labs(x="",y=paste0("Odds Ratio (",conf_label,")"))+
    theme_light()+
    theme(
      axis.text.y = element_text(size=10,color="black"),
      legend.position.inside = c(.85,.1),
      legend.title = element_blank(),
      legend.background = element_blank()
    )+
    scale_color_manual(values=c("darkgrey","coral"))


  out <- list()
  out$`Odds Ratios` <- OR_df
  out$`Cumulative Odds Ratio Plot` <- p
  class(out) <- "CORPlot"
  return(out)
}
