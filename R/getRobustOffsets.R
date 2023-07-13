#' Returns sample offsets (+ study offsets if used with sampleMeta).
#' @param genexpMatrix Gene expression matrix with genes as rows, samples as columns.
#' @param sampleMeta Dataframe with Study_ID and Sample_ID of each sample.
#' @return
#'     If used without sampleMeta: dataframe with sample offsets.
#'     If used with sampleMeta: list with 2 objects:
#'     - dataframe with study offsets and sample offset SD.
#'     - dataframe with sample offsets.
#' @examples
#' \dontrun{
#' robustOffsets_without_using_metainformation <-
#'    getRobustOffsets(genexpMatrix = genexpMatrix_example)
#'
#' robustOffsets_using_metainformation <-
#'    getRobustOffsets(genexpMatrix = genexpMatrix_example, sampleMeta = sampleMeta_example)
#'
#' comparison_df <-
#'    merge(
#'       x = robustOffsets_without_using_metainformation,
#'       y = robustOffsets_using_metainformation$sampleOffsets,
#'       by = "Sample_ID"
#'    )
#'
#' summary(lm(sampleOffset.y ~ sampleOffset.x, data = comparison_df))
#'
#' }
#' @export


getRobustOffsets <- function (genexpMatrix, sampleMeta = NULL)
{
  turn_genexprMatrix_in_long_format <- function(genexpMatrix) {
    output <- as.data.frame(t(genexpMatrix))
    output$Sample <- rownames(output)
    output <- reshape2::melt(output, id.vars = c("Sample"))
    colnames(output) <- c("Sample", "Gene", "expr")
    output$Sample <- as.character(output$Sample)
    output$Gene <- as.character(output$Gene)
    return(output)
  }
  if (is.null(sampleMeta)) {
    print("Busy with single-project mode...")
    genexpMatrix <- turn_genexprMatrix_in_long_format(genexpMatrix)

    mean_genexp <- stats::aggregate(expr ~ Gene, data = genexpMatrix,
                                    FUN = mean)

    colnames(mean_genexp)[2] <- "mean_genexp"
    genexpMatrix <- merge(x = genexpMatrix, y = mean_genexp, by = "Gene")

    genexpMatrix <- subset(genexpMatrix, is.finite(mean_genexp))
    print(paste0(length(unique(genexpMatrix$Gene)), " genes have finite genexp in all samples"))

    genexpMatrix$expr <- genexpMatrix$expr - genexpMatrix$mean_genexp
    model_output <- lme4::lmer(expr ~ (1 | Sample), data = genexpMatrix)
    output <- lme4::ranef(model_output)$Sample
    output$Sample_ID <- rownames(output)
    colnames(output)[1] <- "log_sampleOffset"
    output <- output[, c("Sample_ID", "log_sampleOffset")]
    output$sampleOffset <- exp(output$log_sampleOffset)
  }
  else {
    print("Busy with multi-project mode...")
    if (class(sampleMeta) != "data.frame") {
      stop("sampleMeta must be of class 'data.frame'")
    }
    else if (sum(colnames(sampleMeta) %in% c("Study_ID",
                                             "Sample_ID")) < 2) {
      stop("sampleMeta must contain columns 'Study_ID' and 'Sample_ID'")
    }
    else if (!sum(colnames(genexpMatrix) %in% sampleMeta$Sample_ID) ==
             nrow(sampleMeta)) {
      stop("not all samples in sampleMeta are in genexpMatrix")
    }
    else {
      genexpMatrix <- turn_genexprMatrix_in_long_format(genexpMatrix)
      projects <- unique(sampleMeta$Study_ID)
      output <- list()
      output$studyOutput <- data.frame(Study_ID = projects,
                                         studyOffset = NA, log_studyOffset = NA, log_studyOffset_SE = NA,
                                         log_studyOffset_t.value = NA, SD_sampleOffsets = NA)
      genexpMatrix <- merge(x = genexpMatrix, y = sampleMeta,
                            by.x = "Sample", by.y = "Sample_ID")
      mean_genexp_byProject <- stats::aggregate(expr ~
                                                  Gene + Study_ID, data = genexpMatrix, FUN = mean)
      mean_genexp_acrossProjects <- stats::aggregate(expr ~
                                                       Gene, data = mean_genexp_byProject, FUN = mean)
      colnames(mean_genexp_acrossProjects)[2] <- "mean_genexp_acrossProjects"
      for (i in 1:length(projects)) {
        print(paste0("Busy with project ", projects[i]))
        samples_subset <- subset(sampleMeta, Study_ID ==
                                   projects[i])
        genexpMatrix_subset <- genexpMatrix[genexpMatrix$Sample %in%
                                              samples_subset$Sample_ID, ]
        genexpMatrix_subset <- merge(x = genexpMatrix_subset,
                                     y = mean_genexp_acrossProjects, by = "Gene")
        genexpMatrix_subset$expr <- genexpMatrix_subset$expr -
          genexpMatrix_subset$mean_genexp_acrossProjects
        model_output <- lme4::lmer(expr ~ (1 | Sample),
                                   data = genexpMatrix_subset)
        model_output_summary <- summary(model_output)
        sample_offsets_temp <- lme4::ranef(model_output)$Sample
        sample_offsets_temp$Sample_ID <- rownames(sample_offsets_temp)
        colnames(sample_offsets_temp)[1] <- "log_sampleOffset"
        sample_offsets_temp$log_sampleOffset <- sample_offsets_temp$log_sampleOffset +
          stats::coef(model_output_summary)[1, 1]
        sample_offsets_temp <- sample_offsets_temp[,
                                                   c("Sample_ID", "log_sampleOffset")]
        sample_offsets_temp$sampleOffset <- exp(sample_offsets_temp$log_sampleOffset)
        output$studyOutput[i, "studyOffset"] <- exp(stats::coef(model_output_summary)[1,
                                                                                          1])
        output$studyOutput[i, c("log_studyOffset",
                                  "log_studyOffset_SE", "log_studyOffset_t.value")] <- stats::coef(model_output_summary)[1,
                                  ]
        output$studyOutput[i, "SD_sampleOffsets"] <- stats::sd(sample_offsets_temp$sampleOffset)
        if (i == 1) {
          output$sampleOffsets <- sample_offsets_temp
        }
        else {
          output$sampleOffsets <- rbind(output$sampleOffsets,
                                        sample_offsets_temp)
        }
      }
    }
  }
  return(output)
}
