test_that("correlation sample offsets with and without meta info", {

  robustOffsets_using_metainformation <- getRobustOffsets(genexpMatrix_example, sampleMeta_example)
  robustOffsets_without_using_metainformation <- getRobustOffsets(genexpMatrix_example)

  comparison_df <-
    merge(
      x = robustOffsets_using_metainformation$sampleOffsets,
      y = robustOffsets_without_using_metainformation,
      by = "Sample_ID"
    )

  model_summary <- summary(lm(sampleOffset.y ~ sampleOffset.x, data = comparison_df))

  expect_gt(model_summary$r.squared, 0.999)

})
