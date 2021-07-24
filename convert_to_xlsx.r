library(stringr)
library("xlsx")
options(warn = -1)
# install.packages('xlsx')

args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  print('parameters needed for converting to xlsx')
} else{
  workDir <- args[1]
  patientID <- args[2]
  convertID <- args[3]
}

## for test ===================
# workDir <- '/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/EB72'
# patientID <- 'EB72'
# convertID <- 'snv'
## test end ....................

## create folders ====
subfolders <- c('Mutation_analysis', 
                'Mutation_analysis/snv', 
                'Mutation_analysis/CGI', 
                'Mutation_analysis/indel', 
                'Epitope_prediction', 
                'Epitope_prediction/snv_based', 
                'Epitope_prediction/indel_based', 
                'Epitope_prediction/fusion_genes', 
                'HLA', 
                'HLA/DKMS', 
                'HLA/In_silico', 
                'Gene_Expression'
)
output_dir <- '/omics/odcf/analysis/OE0422_projects/Immuno-Patients-NCT/sequencing/exon_sequencing/results_per_pid'
output_dir <- file.path(output_dir, patientID)
dir.create(output_dir)
output_dirs <- paste(output_dir, subfolders, sep = '/')
sapply(output_dirs, dir.create)

## functions ====
convert_to_xlsx <- function(file.input, file.output){
  t1 <- read.table(file.input, header = TRUE, row.names = NULL, sep = '\t')
  if (nrow(t1)>0){
    write.xlsx(t1, file = file.output, append = FALSE, row.names=FALSE)
  }
}


convert_main <- function(convertID) {
  if (convertID == 'snv'){
    inputDir <- paste(workDir, '8_chose_neoepitode', sep = '/')
  }else if(convertID == 'indel'){
    inputDir <- paste(workDir, '4_indel_based_prediction', sep = '')  
  }
  file.input <- list.files(inputDir, pattern = '^MHC.*', full.names = TRUE)
  file.name <- str_match(file.input, pattern = '(MHC.*).tab')[,2]
  file.output <- paste(output_dir, '/Epitope_prediction/snv_based/', 
                        file.name, '.xlsx', 
                        sep = '')
  mapply(convert_to_xlsx, file.input, file.output)
}


## main ==== 
convert_main(convertID)
