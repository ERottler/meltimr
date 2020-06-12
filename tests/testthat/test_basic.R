context("Basic functions")
library(meltimr)

test_that("test mean average with NA treatment", {
  expect_equal(mea_na(c(1, 2, 3)), 2)
  expect_equal(mea_na(c(1, 2, 3, NA)), 2)
  expect_equal(mea_na(c(NA, NA, NA)), NA)
})

test_that("test sum with NA treatment", {
  expect_equal(sum_na(c(1, 2, 3)), 6)
  expect_equal(sum_na(c(1, 2, 3, NA)), 6)
  expect_equal(sum_na(c(NA, NA, NA)), NA)
})

test_that("test mean average with NA treatment", {
  expect_equal(mea_na(c(1, 2, 3)), 2)
  expect_equal(mea_na(c(1, 2, 3, NA)), 2)
  expect_equal(mea_na(c(NA, NA, NA)), NA)
})

test_that("test min with NA treatment", {
  expect_equal(min_na(c(1, 2, 3)), 1)
  expect_equal(min_na(c(1, 2, 3, NA)), 1)
  expect_equal(min_na(c(NA, NA, NA)), NA)
})

test_that("test max with NA treatment", {
  expect_equal(max_na(c(1, 2, 3)), 3)
  expect_equal(max_na(c(1, 2, 3, NA)), 3)
  expect_equal(max_na(c(NA, NA, NA)), NA)
})

