test_that("assignMarkerCombinations produces expected output", {
  # Load example data
  df_markerPos <- readRDS(test_path("reference1.rds"))

  # Run your function
  result_simple <- assignMarkerCombinations(data_markerPos = df_markerPos, mode = "simple")
  result_exhaustive <- assignMarkerCombinations(data_markerPos = df_markerPos, mode = "exhaustive")

  # Load reference
  ref_simple <- readRDS(test_path("reference2_simple.rds"))
  ref_exhaustive <- readRDS(test_path("reference2_exhaustive.rds"))

  # Compare to a reference file
  expect_equal(result_simple, ref_simple)
  expect_equal(result_exhaustive, ref_exhaustive)
})
