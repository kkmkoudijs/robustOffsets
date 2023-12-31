% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getRobustOffsets.R
\name{getRobustOffsets}
\alias{getRobustOffsets}
\title{Returns sample offsets (+ study offsets if used with sampleMeta).}
\usage{
getRobustOffsets(genexpMatrix, sampleMeta = NULL)
}
\arguments{
\item{genexpMatrix}{Gene expression matrix with genes as rows, samples as columns.}

\item{sampleMeta}{Dataframe with Study_ID and Sample_ID of each sample.}
}
\value{
If used without sampleMeta: dataframe with sample offsets.
    If used with sampleMeta: list with 2 objects:
    - dataframe with study offsets and sample offset SD.
    - dataframe with sample offsets.
}
\description{
Returns sample offsets (+ study offsets if used with sampleMeta).
}
\examples{
\dontrun{
robustOffsets_without_using_metainformation <-
   getRobustOffsets(genexpMatrix = genexpMatrix_example)

robustOffsets_using_metainformation <-
   getRobustOffsets(genexpMatrix = genexpMatrix_example, sampleMeta = sampleMeta_example)

comparison_df <-
   merge(
      x = robustOffsets_without_using_metainformation,
      y = robustOffsets_using_metainformation$sampleOffsets,
      by = "Sample_ID"
   )

summary(lm(sampleOffset.y ~ sampleOffset.x, data = comparison_df))

}
}
