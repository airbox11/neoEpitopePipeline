
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  print('parameters needed for converting to xlsx')
} else{
  workDir <- args[1]
  mhc.input <- args[2]
}

## test ==== ====
test <- TRUE
test <- FALSE
if (test){
  # workDir <- '/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/K26K-P7V4JK-tumor11'
  workDir <- '/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/MO79'
  mhc.input <- 'MHCI_epitopes_RNAseq_netMHCpan4_1.tab_renameCol'
}


main_run <- function() {
  dir1 <- file.path(workDir, '8_chose_neoepitode')
  setwd(dir1)
  
  ## MHCI table ==============
  
  df.mhcI <- read.table(mhc.input, header=TRUE, stringsAsFactors = FALSE, sep = '\t')
  df.mhcI$LossAllele <- tolower(gsub("HLA-(.)\\*(..):(..)", "hla_\\1_\\2_\\3", df.mhcI$MHC_allele))
  
  
  ## loh table ==============
  file.loh <- '../5_LOHHLA/example-out/example.10.DNA.HLAlossPrediction_CI.xls'
  
  if(!file.exists(file.loh)){
    print(file.path(workDir,'5_LOHHLA/example-out'))
    stop('=========== =========== no LOH result exist. ')
  }
  df.loh <- read.table(file.loh, header=TRUE, stringsAsFactors = FALSE, sep = '\t')
  df.loh.lite <- df.loh[,c("LossAllele", "PVal_unique")]
  
  ## merge tables ==============
  df.mhcI.loh <- merge(df.mhcI, df.loh.lite, by.x='LossAllele', by.y='LossAllele', all.x=TRUE)
  df.mhcI.loh[!is.na(df.mhcI.loh$PVal_unique),]$LossAllele <- 'Yes'
  df.mhcI.loh[is.na(df.mhcI.loh$PVal_unique),]$LossAllele <- 'No'
  
  df.mhcI.loh2 <- df.mhcI.loh[,c(2,3,ncol(df.mhcI.loh),1,4:(ncol(df.mhcI.loh)-1))]
  mhc.output <- paste0(mhc.input, '_loh')
  write.table(df.mhcI.loh2, file = mhc.output, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = '\t')
}
main_run()
