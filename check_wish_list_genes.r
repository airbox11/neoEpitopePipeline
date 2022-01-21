args1 <- commandArgs(trailingOnly = TRUE)
tsv <- args1[1]
outputFile <- args1[2]

## test :
# workDir <- '~/mhc/H021-S4CLSR/3_add_expression'
## test end 


wishList <- '/omics/groups/OE0422/internal/yanhong/documentation/NCT_gene_list_20210511.txt'

tb1 <- read.table(tsv, header = TRUE, sep = '\t', stringsAsFactors = FALSE, comment.char = '')
genes <- read.table(wishList, header = TRUE, sep = '\t',stringsAsFactors = FALSE)[,1]

tb2 <- tb1[tb1$name %in% genes,]
write.table(tb2, file = outputFile, row.names = FALSE, col.names = TRUE, sep = '\t', quote = FALSE)


