# robustOffsets: RNA-seq normalization using a reference panel of low-variability genes

## Condense a panel of reference genes into a single sample offset, which captures systematic systematic changes in gene expression. 

### Abstract
One key assumption underlying standard RNA-seq normalization is that many genes exist that are not differentially expressed across samples and can serve as reference genes. Violation of this assumption reduces statistical power and could result in false positive results.

We develop a new method to normalize gene expression by extracting a data-driven panel of reference genes through a variance criterion using a mixed model approach. We use data containing results from several to many studies such is available from public data repositories and define a normalization factor for downstream analysis based on the derived reference panel. To illustrate the method a set of tumor studies is used. The method is validated by associating normalized gene expression data with biological tumor characteristics.

Gene expression stability is most robustly quantified by the mean within-tumor standard deviation (σintra[i]) when analyzing a full set of tumor studies. Expression of genes with low mean σintra[i] are systematically shifted in the same direction within a sample, which is robustly captured by fitting a random effects model. The observed systematic variability shared by low-variability genes has meaningful biological associations with variables which are expected to produce systematic shifts in gene expression such as the fraction of tumor cells and the number of genome duplications, which are not detectable using standard methods.  


## How to install

Note: this package requires R>=3.5. 

- Install latest version of robustOffsets directly from Github using `devtools`:
  ```
library(devtools)
devtools::install_github("kkmkoudijs/robustOffsets")
```
