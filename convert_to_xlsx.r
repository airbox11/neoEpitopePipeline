library(stringr)
library(WriteXLS)
source('/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline/change_names_function.r')
options(warn = -1)


args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  print('parameters needed for converting to xls')
} else{
  workDir <- args[1]
  output_dir <- args[2]
  convertID <- args[3]

}



  ## for test ===================
  # workDir <- '/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/promise/batch_process_20230302/result/S014-VT1D4H_T1T2_tumor11'
  # output_dir <- '/omics/odcf/analysis/OE0422_projects/promise/results_per_pid_2/S014-VT1D4H/Epitope_prediction/snv_based/T1T2_tumor11'
  # convertID <- 'snv'
  # workDir <- '/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/p005144'

# output_dir <- '/omics/odcf/analysis/OE0422_projects/Immuno-Patients-NCT/sequencing/exon_sequencing/results_per_pid/p005144/Epitope_prediction/indel_based'
# convertID <- 'indel'

  # workDir <- '/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/promise/batch_process_20230302/result/S014-2CDKKU_T1T2_tumor11'
  # output_dir <- '/omics/odcf/analysis/OE0422_projects/promise/promise_hg38/S014-2CDKKU/Epitope_prediction/snv_based/T1T2_tumor11'
  # convertID <- 'snv'
  

  ## test end ....................

## functions ====

convert_to_xls <- function(file.input, file.output){
  t1 <- read.table(file.input, header = TRUE, row.names = NULL, sep = '\t', stringsAsFactors = FALSE, quote="")

  if (nrow(t1)>0){

    t1 <- change.names(t1)
    WriteXLS(t1, file.output)
    print(file.output)

  }
}

convert_main <- function(convertID) {
  if (convertID == 'snv'){
    inputDir <- paste(workDir, '8_chose_neoepitode', sep = '/')
    file.input <- list.files(inputDir, full.names = TRUE, pattern="_wish")
    file.input2 <- list.files(inputDir, full.names = FALSE, pattern="_wish")
    print(workDir)
    file.name <- str_match(file.input2, pattern = '(.*)\\.[tab|csv]')[,2]
    file.output <- paste(output_dir, '/',
                         file.name, '.xlsx', 
                         sep = '')

  }else if(convertID == 'indel'){

    inputDir <- paste(workDir, '/4_indel_based_prediction', sep = '')  
    file.input <- list.files(inputDir, pattern = '^indel.*(long|wish$)', full.names = TRUE)

    if (length(file.input) == 0) {
      print('===== indel vcf is empty:')
      print(paste0('===== ',inputDir))
      return(0)
    }

    file.name <- str_match(file.input, pattern = '.*/(indel.*).tsv')[,2]
    file.output <- paste(output_dir, '/',
                         file.name, '.xlsx', 
                         sep = '')
  }else if(convertID %in% c('wishList' ,'fusionsTsv')){
    file.input <- workDir
    file.output <- paste0(output_dir, '/', convertID, '.xlsx')
    print(file.input)
  }
  mapply(convert_to_xls, file.input, file.output)
}


## main ==== 
convert_main(convertID)

