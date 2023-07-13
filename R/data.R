#' Dataframe with the estimated mean 'within study' SD across the 32 included tumor studies.
#'
#' @format A data frame with 10,571 rows and 5 variables:
#' \describe{
#'   \item{Gene_ID}{Ensembl gene ID}
#'   \item{Gene_name}{Gene symbol}
#'   \item{mean_Intra_project_sigma}{Estimated mean within study SD}
#'   \item{mean_Intra_project_sigma_lower_limit_95pct_CI}{Lower limit of 95% confidence interval}
#'   \item{mean_Intra_project_sigma_upper_limit_95pct_CI}{Upper limit of 95% confidence interval}
#' }
"mean_intra_project_sigma"


#' Matrix with log-transformed cpm values of 500 references genes identified in TCGA studies.
#'
#' A dataset containing gene expression data of the 9,724 tumor samples
#' accross the 32 different TCGA tumor studies.
#'
#' @format A matrix with 500 rows and 9,724 columns.
"genexpMatrix_example"

#' Contains the abbreviated sample meta information.
#'
#' This data describes which TCGA study each sample belongs to.
#'
#' @format A data frame with 9,724 rows and 2 variables:
#' \describe{
#'   \item{Study_ID}{Unique ID of the study}
#'   \item{Sample_ID}{Unique ID of the sample, must exist in corresponding genexpression data}
#' }
#' @source \url{https://gdc.cancer.gov/resources-tcga-users/tcga-code-tables/tcga-study-abbreviations}
"sampleMeta_example"
