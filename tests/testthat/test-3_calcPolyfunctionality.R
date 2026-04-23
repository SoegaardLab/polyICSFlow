# normalize dataframes by removing all factor levels (ensure same row order)
normalize_df <- function(df) {
  df[] <- lapply(df, function(x) if (is.factor(x)) as.character(x) else x)
  dplyr::arrange(df, !!!rlang::syms(names(df)))  # sort by all columns
}

test_that("calcPolyfunctionality produces expected output", {
  # Load example data
  df <- readRDS(test_path("reference2_exhaustive_md.rds"))

  # Run your function
  result <- calcPolyfunctionality(x = df,
                                  md_cols = c("ID"),
                                  pop_col = "cell_type",
                                  resolution = "MarkerComb",
                                  condition_col = "Stimulation",
                                  background_val = "Unstim")

  ref <- readRDS(test_path("reference3.rds"))

  # Compare to a reference file
  expect_equal(normalize_df(result), normalize_df(ref), tolerance = 1e-4)
})
