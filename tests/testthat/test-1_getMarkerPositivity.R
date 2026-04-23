test_that("getMarkerPositivity produces expected output", {
  # Load example data
  gs <- flowWorkspace::load_gs(test_path("GatingSet"))

  # Run your function
  result <- getMarkerPositivity(gs, gate_names = c("IFN+","TNFa+","IL2+","CD107a+"))

  # Load reference
  ref <- readRDS(test_path("reference1.rds"))

  # Compare to a reference file
  expect_equal(result, ref)
})
