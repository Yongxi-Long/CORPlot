test_that("PerformPO returns expected structure", {
  skip_if_not_installed("VGAM")

  set.seed(123)
  dat <- data.frame(
    mRS   = factor(sample(0:3, 50, replace = TRUE), ordered = TRUE),
    group = sample(c("A", "B"), 50, replace = TRUE)
  )

  res <- PerformPO(dat, mRS ~ group, GroupName = "group")

  expect_s3_class(res, "data.frame")
  expect_named(res, c("Label", "OR", "lower95CI", "upper95CI"))
  expect_true(all(c("OR", "lower95CI", "upper95CI") %in% colnames(res)))
  expect_true(nrow(res)==1)
  expect_true(all(is.character(res$Label)))
  expect_type(res$OR, "double")
})

test_that("GroupName is inferred when not supplied", {
  skip_if_not_installed("VGAM")

  dat <- data.frame(
    mRS   = factor(sample(0:2, 30, replace = TRUE), ordered = TRUE),
    group = sample(c("A", "B"), 30, replace = TRUE)
  )

  expect_warning({
    res <- PerformPO(dat, mRS ~ group)
  })
  expect_s3_class(res, "data.frame")
})


test_that("upper argument changes the log common OR sign", {
  skip_if_not_installed("VGAM")

  dat <- data.frame(
    mRS   = factor(rep(0:2, each = 10), ordered = TRUE),
    group = rep(c("A", "B"), 15)
  )

  res1 <- PerformPO(dat, mRS ~ group, GroupName = "group", upper = FALSE)
  res2 <- PerformPO(dat, mRS ~ group, GroupName = "group", upper = TRUE)

  expect_true(abs(log(res1$OR) + log(res2$OR)) <= 1e-5)
})

test_that("invalid inputs trigger errors", {
  skip_if_not_installed("VGAM")

  dat <- data.frame(
    mRS   = factor(sample(0:2, 10, replace = TRUE), ordered = TRUE),
    group = sample(c("A", "B"), 10, replace = TRUE)
  )

  # formula must be a formula
  expect_error(PerformPO(dat, "mRS ~ group"))

  # data must be a data frame
  expect_error(PerformPO(as.matrix(dat), mRS ~ group))

  # GroupName not in data
  expect_error(PerformPO(dat, mRS ~ group, GroupName = "nonexistent"))
})


test_that("function handles failure to compute CIs gracefully", {
  skip_if_not_installed("VGAM")

  dat <- data.frame(
    mRS   = factor(c(0,rep(1,9)), ordered = TRUE),
    group = rep(c("A", "B"), 10)
  )

  res <- suppressWarnings(
    PerformPO(dat, mRS ~ group, GroupName = "group")
  )
  expect_true(all(c("lower95CI", "upper95CI") %in% names(res)))
  # allow NAs if confint fails
  expect_true(all(is.finite(res$OR)))
})
