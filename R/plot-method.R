#' @export
#' @method plot CORPlot
plot.CORPlot <- function(x,...){
  if (!inherits(x, "CORPlot")) {
    stop("Object must be of class 'CORPlot'")
  }

  p <- x$`Cumulative Odds Ratio Plot`

  if (!inherits(p, "ggplot")) {
    stop("No valid ggplot object found in 'Cumulative Odds Ratio Plot'")
  }

  print(p)
  invisible(p)  # return the plot invisibly, so it can be assigned if needed
}

#' @export
#' @method print CORPlot
print.CORPlot <- function(x, digits = 3, format = "markdown", ...) {
  if (!inherits(x, "CORPlot")) {
    stop("`x` must be a 'CORPlot' object")
  }

  ORs <- x$`Odds Ratios`
  if (is.null(ORs)) {
    stop("CORPlot object does not contain an `Odds Ratio` element.")
  }

  # Round numeric columns
  num_cols <- vapply(ORs, is.numeric, logical(1))
  ORs[num_cols] <- lapply(ORs[num_cols], round, digits = digits)

  # fallback: if knitr not available, use base print
  if (!requireNamespace("knitr", quietly = TRUE)) {
    message("Package 'knitr' not installed; using base print.")
    print(ORs, ...)
    return(invisible(x))
  }

  # Pretty print with knitr::kable
  out <- knitr::kable(
    ORs,
    format = format, # NULL → auto (markdown, html, latex depending on context)
    align = "c",
    caption = "Odds Ratios"
  )
  print(out)

  invisible(x)
}
