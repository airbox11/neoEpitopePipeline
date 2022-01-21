library(stringr) 
library(biomaRt)
# BiocManager::version()
# BiocManager::valid()
# install.packages('biomaRt')
# ensembl <- useEnsembl(biomart = "genes", dataset = "hsapiens_gene_ensembl")

args1 <- commandArgs(trailingOnly = TRUE)


netMHCpanID <- args1[1]
workDir <- args1[2]
tcga <- args1[3]


## for test: =========================
# netMHCpanID <- 'netMHCpan4_1'
# workDir <- '/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/EH63_cell-line01'
# tcga <- 'RNAseq'
## end of test =========================
setwd(workDir)

inputMHCI  <- paste(workDir, '/3_add_expression/MHCI_epitopes_', tcga, '_', netMHCpanID, '.tab', sep = '')
inputMHCII <- paste(workDir, '/3_add_expression/MHCII_epitopes_', tcga, '.tab', sep = '')

columns_table <- '/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline/columns_table.csv'
ct.df <- read.table(file = columns_table, sep = '\t', header = TRUE, stringsAsFactors = FALSE, fill = TRUE)

old_mart <- useMart(biomart="ENSEMBL_MART_ENSEMBL",
                    host="grch37.ensembl.org",
                    path="/biomart/martservice",
                    dataset="hsapiens_gene_ensembl"
                    )


## 1) filter files with tcga data ====
## 1.1) filter file for MHCI: ====
get_ref_long <- function(ref){
    ref.fa <- readLines(paste('./2_SNVs_based_neoepitope_prediction/', netMHCpanID, '/ref.fa', sep = ''))
    ref.long <- grep(ref, ref.fa, ignore.case = TRUE, value = TRUE)[1]
    return(ref.long)
}

compare_ref_mut <- function(ref, mut){
    for (i in c(1:nchar(ref))){
        ref.c <- substr(ref, i,i)
        mut.c <- substr(mut, i,i)
        if (ref.c != mut.c){
            return(i)
        }
    }
}

get_pos <- function(ref, mut,gene){
    Epitope_length <- nchar(ref)
    Mut_pos_epitope <- compare_ref_mut(ref,mut)
    WildType_long_peptide <- get_ref_long(ref)
    if (is.na(WildType_long_peptide)){
        ref <- substr(ref,1,(nchar(ref)-1))
        WildType_long_peptide <- get_ref_long(ref)
    }
    compare1 <- str_match(WildType_long_peptide, paste('(.*)',ref,'(.*)',sep = ''))
    len_prefix <- nchar(compare1[2])
    len_suffix <- nchar(compare1[3])
    
    Mutant_long_peptide <- paste(compare1[2], mut, compare1[3], sep = '')
    Epi_pos_in_longpep <- Mut_pos_epitope + len_prefix

    return(c(Epitope_length, Mut_pos_epitope, WildType_long_peptide, Mutant_long_peptide, Epi_pos_in_longpep))
}

if (netMHCpanID == 'netMHCstabpan') {
    mhc1.rna.select <- ct.df$mhc1.stab.rna.select[ct.df$mhc1.stab.rna.select != ""]
    mhc1.rna.rename <- ct.df$mhc1.stab.rna.rename[ct.df$mhc1.stab.rna.rename != ""]
    mhc1.rna.reorder <- ct.df$mhc1.stab.rna.reorder[ct.df$mhc1.stab.rna.reorder != ""]
    mhc1.tcga.select <- ct.df$mhc1.stab.tcga.select[ct.df$mhc1.stab.tcga.select != ""]
    mhc1.tcga.rename <- ct.df$mhc1.stab.tcga.rename[ct.df$mhc1.stab.tcga.rename != ""]
    mhc1.tcga.reorder <- ct.df$mhc1.stab.tcga.reorder[ct.df$mhc1.stab.tcga.reorder != ""]
}else if (netMHCpanID == 'netMHCpan4_1') {
    mhc1.rna.select <- ct.df$mhc1.rna.select[ct.df$mhc1.rna.select != ""]
    mhc1.rna.rename <- ct.df$mhc1.rna.rename[ct.df$mhc1.rna.rename != ""]
    mhc1.rna.reorder <- ct.df$mhc1.rna.reorder[ct.df$mhc1.rna.reorder != ""]
    mhc1.tcga.select <- ct.df$mhc1.tcga.select[ct.df$mhc1.tcga.select != ""]
    mhc1.tcga.rename <- ct.df$mhc1.tcga.rename[ct.df$mhc1.tcga.rename != ""]
    mhc1.tcga.reorder <- ct.df$mhc1.tcga.reorder[ct.df$mhc1.tcga.reorder != ""]
}

filter_tcga_RNAseq_mhc1 <- function(){
    file.mhci <- inputMHCI
    f1 <- read.table(file.mhci, sep = '\t', header = TRUE, stringsAsFactors = FALSE)
    if (tcga == 'RNAseq'){
        f2 <- f1[,mhc1.rna.select]
        colnames(f2) <- mhc1.rna.rename
    }else{
        f1 <- read.table(file.mhci, sep = '\t', header = TRUE, stringsAsFactors = FALSE)
        f2 <- f1[, mhc1.tcga.select]
        colnames(f2) <- mhc1.tcga.rename
    }
    
    f3 <- f2[!f2$`Mutant peptide` == f2$`Wildtype peptide`,]
    d1 <- as.data.frame(t(mapply(function(ref, mut, gene) get_pos(ref, mut, gene), f3$`Wildtype peptide`, f3$`Mutant peptide`, 
                                 f3$Gene)))
    colnames(d1) <- c('Epitope_length', 'Mut_pos_epitope', 'WildType_long_peptide', 'Mutant_long_peptide', 'Epi_pos_in_longpep')
    f4 <- cbind(f3,d1)
    f5 <- f4[(f4$Aff.nM_mut <= 2000 & f4$BindLevel_mut != 'nonB')| 
                 (f4$BindLevel_mut == 'nonB' & f4$Aff.nM_mut <= 1000 ), ]

    if (tcga == 'RNAseq'){
        f6 <- f5[,mhc1.rna.reorder]
        f6 <- f6[!is.na(f5$Gene),]
        f6$freAlt <- as.numeric(as.character(f6$freAlt))
        f6$FPKM[is.na(f6$FPKM)] <- 0
        f6$freAlt[is.na(f6$freAlt)] <- 0
        f6$expression <- f6$FPKM*f6$freAlt
    }else{
        f6 <- f5[, mhc1.tcga.reorder]
        f6 <- f6[!is.na(f5$Gene),]
        f6$expression <- f6$Median*f6$mut_freq
    }
    write.table(f6, file = paste(workDir, '/8_chose_neoepitode/MHCI_epitopes_',tcga, '_', netMHCpanID, '.tab',sep = ''), sep = '\t', row.names = FALSE, col.names = TRUE, quote = FALSE)
}

mhc2.rna.select <- ct.df$mhc2.rna.select[ct.df$mhc2.rna.select != ""]
mhc2.rna.rename <- ct.df$mhc2.rna.rename[ct.df$mhc2.rna.rename != ""]
mhc2.rna.reorder <- ct.df$mhc2.rna.reorder[ct.df$mhc2.rna.reorder != ""]
mhc2.tcga.select <- ct.df$mhc2.tcga.select[ct.df$mhc2.tcga.select != ""]
mhc2.tcga.rename <- ct.df$mhc2.tcga.rename[ct.df$mhc2.tcga.rename != ""]
mhc2.tcga.reorder <- ct.df$mhc2.tcga.reorder[ct.df$mhc2.tcga.reorder != ""]

filter_tcga_RNAseq_mhc2 <- function(){
    file.mhci <- inputMHCII
    f1 <- read.table(file.mhci, sep = '\t', header = TRUE, stringsAsFactors = FALSE)
    if (tcga == 'RNAseq'){
        f2 <- f1[,mhc2.rna.select]
        colnames(f2) <- mhc2.rna.rename
    }else{
        f2 <- f1[,mhc2.tcga.select]
        colnames(f2) <- mhc2.tcga.rename
    }
    
    f3 <- f2[!f2$`Mutant peptide` == f2$`Wildtype peptide`,]
    d1 <- as.data.frame(t(mapply(function(ref, mut, gene) get_pos(ref, mut, gene), f3$`Wildtype peptide`, f3$`Mutant peptide`, 
                                 f3$Gene)))
    colnames(d1) <- c('Epitope_length', 'Mut_pos_epitope', 'WildType_long_peptide', 'Mutant_long_peptide', 'Epi_pos_in_longpep')
    f4 <- cbind(f3,d1)
    f5 <- f4[(f4$Aff.nM_mut <= 2000 & f4$BindLevel_mut != 'nonB')| 
                 (f4$BindLevel_mut == 'nonB' & f4$Aff.nM_mut <= 1000 ), ]
    
    if (tcga == 'RNAseq'){
        f6 <- f5[, mhc2.rna.reorder]
        f6 <- f6[!is.na(f5$Gene),]
        f6$freAlt <- as.numeric(as.character(f6$freAlt))
        f6$FPKM[is.na(f6$FPKM)] <- 0
        f6$freAlt[is.na(f6$freAlt)] <- 0
        f6$expression <- f6$FPKM*f6$freAlt
    }else{
        f6 <- f5[, mhc2.tcga.reorder]
        f6 <- f6[!is.na(f5$Gene),]
        f6$expression <- f6$Median*f6$mut_freq
    }
    write.table(f6, file = paste(workDir, '/8_chose_neoepitode/MHCII_epitopes_',tcga,'.tab',sep = ''), sep = '\t', row.names = FALSE, col.names = TRUE, quote = FALSE)
}

filter_tcga_RNAseq_mhc1()
filter_tcga_RNAseq_mhc2()
