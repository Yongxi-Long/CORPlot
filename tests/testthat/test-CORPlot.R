test_that("CORPlot errors on invalid input combinations", {
  dummy_df <- data.frame(Label = "common OR", OR = 1, lowerCI = 0.8, upperCI = 1.2)
  # Both OR_df and data provided
  expect_error(
    CORPlot(data = iris, formula = Sepal.Length ~ Species, GroupName = "Species", OR_df = dummy_df),
    "either `OR_df` or"
  )
  # Neither OR_df nor data/formula/groupname provided
  expect_error(CORPlot(), "must provide `data`, `formula`, and `GroupName`")
})


test_that("CORPlot works with external OR_df", {
  OR_df <- data.frame(
    Label   = c("<=1", "<=2", "common OR"),
    OR      = c(1.2, 1.5, 1.3),
    lowerCI = c(0.9, 1.1, 1.0),
    upperCI = c(1.6, 2.0, 1.7)
  )

  res <- CORPlot(OR_df = OR_df)
  expect_s3_class(res, "CORPlot")
  expect_true(all(c("Odds Ratios", "Cumulative Odds Ratio Plot") %in% names(res)))
  expect_s3_class(res$`Cumulative Odds Ratio Plot`, "ggplot")
  expect_true(all(c("Label", "OR", "lowerCI", "upperCI", "type") %in% names(res$`Odds Ratios`)))
})


test_that("CORPlot works with internal model fitting", {
  skip_if_not_installed("VGAM")

  # Toy dataset
  df <- data.frame(
    outcome = factor(rep(1:3, each = 10), ordered = TRUE),
    group   = rep(c("A", "B"), length.out = 30)
  )

  res <- CORPlot(
    data = df,
    formula = outcome ~ group,
    GroupName = "group"
  )

  expect_s3_class(res, "CORPlot")
  expect_s3_class(res$`Cumulative Odds Ratio Plot`, "ggplot")
  expect_true(all(c("Label", "OR", "lowerCI", "upperCI", "type") %in% names(res$`Odds Ratios`)))
})

test_that("CORPlot handles label variations for common OR", {
  OR_df <- data.frame(
    Label   = c("<=1", "<=2", "cOR"),  # lowercase variant
    OR      = c(1.2, 1.5, 1.3),
    lowerCI = c(0.9, 1.1, 1.0),
    upperCI = c(1.6, 2.0, 1.7)
  )

  res <- CORPlot(OR_df = OR_df)
  expect_true("common OR" %in% res$`Odds Ratios`$Label)
})
