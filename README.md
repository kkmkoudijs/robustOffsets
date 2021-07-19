# robustOffsets: RNA-seq normalization using a reference panel of low-variability genes

## Condense a panel of reference genes into a single sample offset, which captures systematic systematic changes in gene expression. 

### Abstract
One key assumption underlying standard RNA-seq normalization is that many genes exist that are not differentially expressed across samples and can serve as reference genes. Violation of this assumption reduces statistical power and could result in false positive results.

We develop a new method to normalize gene expression by extracting a data-driven panel of reference genes through a variance criterion using a mixed model approach. We use data containing results from several to many studies such is available from public data repositories and define a normalization factor for downstream analysis based on the derived reference panel. To illustrate the method a set of tumor studies is used. The method is validated by associating normalized gene expression data with biological tumor characteristics.

Gene expression stability is most robustly quantified by the mean within-tumor standard deviation (σintra[i]) when analyzing a full set of tumor studies. Expression of genes with low mean σintra[i] are systematically shifted in the same direction within a sample, which is robustly captured by fitting a random effects model. The observed systematic variability shared by low-variability genes has meaningful biological associations with variables which are expected to produce systematic shifts in gene expression such as the fraction of tumor cells and the number of genome duplications, which are not detectable using standard methods.  


## How to install

Note: this package requires R>=3.5. 

- Install latest version of robustOffsets directly from Github using `devtools`:
```r
library(devtools)
devtools::install_github("kkmkoudijs/robustOffsets")
```

## How to use
The main function in the package is called getRobustOffsets() and can be used in 
2 different ways: 
1. Using a gene expression matrix with gene ID's on the rows and sample ID's on the columns. The values must be already normalized to Counts Per Million (CPM) with all protein-coding genes present. 
2. Or if applicable, the aforementioned gene expression matrix with an additional data.frame specifying to which study a sample belonged to. 

Included with this package are the TCGA datasets with which the main result of the paper can be replicated. 
We start with loading the package and inspecting the included example datasets: 
```r
library(robustOffset)
# genexpMatrix_example has 500 rows (Gene ID's) and 9,724 columns (Sample ID's):
genexpMatrix_example[1:5,1:5]
dim(genexpMatrix_example) 

# sampleMeta_example (optional) has 9,724 rows (Sample ID's) 
# and 2 columns (Study_ID and Sample_ID):
sampleMeta_example[1:5,]
dim(sampleMeta_example) 
```

These 2 commands use getRobustOffsets() in the 2 different ways:
```r
robustOffsets_without_using_metainformation <-
  getRobustOffsets(genexpMatrix_example)

robustOffsets_using_metainformation <-
  getRobustOffsets(genexpMatrix_example, sampleMeta_example)
```

This produces slightly different output in both cases:
1. If getRobustOffsets() is used without the sample meta-information the output is a data.frame called sampleOffsets, 
containing the Sample_ID, the log of the sampleOffset (log_sampleOffset) and the sampleOffset. 
2. If getRobustOffsets() is used with the sample meta-information the output is a list
with 2 data.frames: sampleOffsets and studyOutput. studyOutput contains the study offsets including additional statistics, such as the log_studyOffset and standard error and the standard deviation of the sampleOffsets within the study.

The following code thus allows for directly comparing the sampleOffsets produced using both methods:
```r
comparison_df <-
  merge(
    x = robustOffsets_without_using_metainformation,
    y = robustOffsets_using_metainformation$sampleOffsets,
    by = "Sample_ID"
  )

summary(lm(sampleOffset.y ~ sampleOffset.x, data = comparison_df))
```
As can be seen from the R-squared (99.98%), in this case both methods produce nearly identical sample offsets. 
The main benefit of using the study meta-information is that it allows for comparing the estimated study offsets. 
