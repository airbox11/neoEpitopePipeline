library(stringr) 
library(biomaRt)
# BiocManager::version()
# BiocManager::valid()
# install.packages('biomaRt')
# ensembl <- useEnsembl(biomart = "genes", dataset = "hsapiens_gene_ensembl")

args1 <- commandArgs(trailingOnly = TRUE)

## for test: =========================
# workDir <- '/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline_collection/mhc4.1/K26K-HGXQVM-metastasis22-01'
# args1 <- c("netMHCpanID","K26K-HGXQVM-metastasis22-01",workDir,"RNAseq","Yes")
###
# workDir <- '/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline_collection/mhc4.1/S2914Nr4'
# args1 <- c("S2914Nr4","MD63",workDir,"RNAseq","Yes")
###
# workDir <- '/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline_collection/mhc4.1/S3005Nr1/'
# args1 <- c("S3005Nr1","GO53",workDir,"TCGA-LIHC","No")
###
# args1 <- c('netMHCpanID','K26K-MK6UTZ','/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline_collection/mhc4.1/K26K-MK6UTZ','TCGA-BRCA','No')
### EB72, net4.1 & stabPan 
# workDir <- '/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/EB72'
# args1 <- c("netMHCstabpan", workDir,"RNAseq")
# args1 <- c("netMHCstabpan", workDir,"TCGA-READ")
## end of test =========================

netMHCpanID <- args1[1]
workDir <- args1[2]
tcga <- args1[3]
setwd(workDir)

inputMHCI  <- paste(workDir, '/3_add_expression/MHCI_epitopes_', tcga, '_', netMHCpanID, '.tab', sep = '')
inputMHCII <- paste(workDir, '/3_add_expression/MHCII_epitopes_', tcga, '.tab', sep = '')
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
    mhc1.rna.select <- c('GENE', 'FPKM', 'MHC', 'Peptide', 'Identity', 'Pred', 'Thalf.h.', 'X.Rank_Stab', 'X1.log50k', 'Aff.nM.', 'X.Rank_aff', 'Combined', 'Combined_.rank', 'BindLevel', 'Peptide.1', 'Identity.1', 'Pred.1', 'Thalf.h..1', 'X.Rank_Stab.1', 'X1.log50k.1', 'Aff.nM..1', 'X.Rank_aff.1', 'Combined.1', 'Combined_.rank.1', 'BindLevel.1', 'NM_accessions', 'aaChange', 'sumReads', 'numOfBaseExp', 'dna_freAlt', 'dna_cov', 'freRef', 'freAlt', 'expAlt')
    mhc1.rna.rename <- c('Gene', 'FPKM', 'MHC allele', 'Mutant peptide', 'Identity_mut', 'Pred_mut', 'Thalf.h_mut', 'Rank_Stab_mut', 'log50k_mut', 'Aff.nM_mut', 'Rank_aff_mut', 'Combined_mut', 'Combined_rank_mut', 'BindLevel_mut', 'Wildtype peptide', 'Identity_wt', 'Pred_wt', 'Thalf.h_wt', 'Rank_Stab_wt', 'log50k_wt', 'Aff.nM_wt', 'Rank_aff_wt', 'Combined_wt', 'Combined_rank_wt', 'BindLevel_wt', 'GenBank_entry_mRNA', 'aaChange', 'sumReads', 'numOfBaseExp', 'dna_freAlt', 'dna_cov', 'freRef', 'freAlt', 'expAlt')
    mhc1.rna.reorder <- c('Gene', 'MHC allele', 'aaChange', 'Epitope_length', 'Mutant peptide', 'Identity_mut', 'Pred_mut', 'Thalf.h_mut', 'Rank_Stab_mut', 'log50k_mut', 'Aff.nM_mut', 'Rank_aff_mut', 'Combined_mut', 'Combined_rank_mut', 'BindLevel_mut', 'Wildtype peptide', 'Identity_wt', 'Pred_wt', 'Thalf.h_wt', 'Rank_Stab_wt', 'log50k_wt', 'Aff.nM_wt', 'Rank_aff_wt', 'Combined_wt', 'Combined_rank_wt', 'BindLevel_wt', 'Mut_pos_epitope', 'Epi_pos_in_longpep', 'Mutant_long_peptide', 'WildType_long_peptide', 'geneID', 'GenBank_entry_mRNA', 'FPKM', 'sumReads', 'numOfBaseExp', 'dna_freAlt', 'dna_cov', 'freRef', 'freAlt', 'expAlt')

    mhc1.tcga.select <- c('GENE', 'MHC', 'Peptide', 'Identity', 'Pred', 'Thalf.h.', 'X.Rank_Stab', 'X1.log50k', 'Aff.nM.', 'X.Rank_aff', 'Combined', 'Combined_.rank', 'BindLevel', 'Peptide.1', 'Identity.1', 'Pred.1', 'Thalf.h..1', 'X.Rank_Stab.1', 'X1.log50k.1', 'Aff.nM..1', 'X.Rank_aff.1', 'Combined.1', 'Combined_.rank.1', 'BindLevel.1', 'NM_accessions', 'aaChange', 'mutFre', 'GeneID', 'Mean', 'Median')

    mhc1.tcga.rename <- c('Gene','MHC allele','Mutant peptide','Identity_mut','Pred_mut','Thalf.h_mut','Rank_Stab_mut','log50k_mut','Aff.nM_mut','Rank_aff_mut','Combined_mut','Combined_rank_mut','BindLevel_mut','Wildtype peptide','Identity_wt','Pred_wt','Thalf.h_wt','Rank_Stab_wt','log50k_wt','Aff.nM_wt','Rank_aff_wt','Combined_wt','Combined_rank_wt','BindLevel_wt','GenBank_entry_mRNA','aaChange','mut_freq','GeneID','Mean','Median')

    mhc1.tcga.reorder <- c('Gene', 'MHC allele', 'aaChange', 'Epitope_length', 'Mut_pos_epitope', 'Mutant peptide', 'Identity_mut', 'Pred_mut', 'Thalf.h_mut', 'Rank_Stab_mut', 'log50k_mut', 'Aff.nM_mut', 'Rank_aff_mut', 'Combined_mut', 'Combined_rank_mut', 'BindLevel_mut', 'Wildtype peptide', 'Identity_wt', 'Pred_wt', 'Thalf.h_wt', 'Rank_Stab_wt', 'log50k_wt', 'Aff.nM_wt', 'Rank_aff_wt', 'Combined_wt', 'Combined_rank_wt', 'BindLevel_wt', 'Epi_pos_in_longpep', 'Mutant_long_peptide', 'WildType_long_peptide', 'GeneID', 'GenBank_entry_mRNA', 'mut_freq', 'Mean', 'Median')
}else if (netMHCpanID == 'netMHCpan4_1') {
    mhc1.rna.select <- c('GENE', 'MHC', 'Peptide', 'Score_EL', 'X.Rank_EL', 'Score_BA', 'X.Rank_BA', 'Aff.nM.', 'BindLevel', 'Peptide.1', 'Score_EL.1', 'X.Rank_EL.1', 'Score_BA.1', 'X.Rank_BA.1', 'Aff.nM..1', 'BindLevel.1', 'NM_accessions', 'aaChange', 'FPKM', 'sumReads', 'numOfBaseExp', 'dna_freAlt', 'dna_cov', 'freRef', 'freAlt', 'expAlt')
    mhc1.rna.rename <- c('Gene', 'MHC allele', 'Mutant peptide', 'Score_EL_mut', 'Rank_EL_Mut', 'Score_BA_mut', 'Rank_BA_mut', 'Aff.nM_mut', 'BindLevel_mut', 'Wildtype peptide', 'Score_EL_wt', 'Rank_EL_wt', 'Score_BA_wt', 'Rank_BA_wt', 'Aff.nM_wt', 'BindLevel_wt', 'GenBank_entry_mRNA', 'aaChange','FPKM', 'sumReads', 'numOfBaseExp', 'dna_freAlt', 'dna_cov', 'freRef', 'freAlt', 'expAlt')
    mhc1.rna.reorder <- c('Gene', 'MHC allele', 'Mutant peptide', 'aaChange', 'Epitope_length', 'Mut_pos_epitope', 'Score_EL_mut', 'Rank_EL_Mut', 'Score_BA_mut', 'Rank_BA_mut', 'Aff.nM_mut', 'BindLevel_mut', 'Wildtype peptide', 'Score_EL_wt', 'Rank_EL_wt', 'Score_BA_wt', 'Rank_BA_wt', 'Aff.nM_wt', 'BindLevel_wt', 'Epi_pos_in_longpep', 'Mutant_long_peptide', 'WildType_long_peptide','geneID', 'GenBank_entry_mRNA', 'FPKM','sumReads', 'numOfBaseExp', 'dna_freAlt', 'dna_cov', 'freRef', 'freAlt', 'expAlt')

    mhc1.tcga.select <- c('GENE', 'MHC', 'Peptide', 'Score_EL', 'X.Rank_EL', 'Score_BA', 'X.Rank_BA', 'Aff.nM.', 'BindLevel', 'Peptide.1', 'Score_EL.1', 'X.Rank_EL.1', 'Score_BA.1', 'X.Rank_BA.1', 'Aff.nM..1', 'BindLevel.1', 'NM_accessions', 'aaChange', 'mutFre', 'GeneID', 'Mean', 'Median')
    mhc1.tcga.rename <- c('Gene', 'MHC allele', 'Mutant peptide', 'Score_EL_mut', 'Rank_EL_Mut', 'Score_BA_mut', 'Rank_BA_mut', 'Aff.nM_mut', 'BindLevel_mut', 'Wildtype peptide', 'Score_EL_wt', 'Rank_EL_wt', 'Score_BA_wt', 'Rank_BA_wt', 'Aff.nM_wt', 'BindLevel_wt', 'GenBank_entry_mRNA', 'aaChange', 'mut_freq', 'GeneID', 'Mean', 'Median')
    mhc1.tcga.reorder <- c('Gene', 'MHC allele', 'Mutant peptide', 'aaChange', 'Epitope_length', 'Mut_pos_epitope', 'Score_EL_mut', 'Rank_EL_Mut', 'Score_BA_mut', 'Rank_BA_mut', 'Aff.nM_mut', 'BindLevel_mut', 'Wildtype peptide', 'Score_EL_wt', 'Rank_EL_wt', 'Score_BA_wt', 'Rank_BA_wt', 'Aff.nM_wt', 'BindLevel_wt', 'Epi_pos_in_longpep', 'Mutant_long_peptide', 'WildType_long_peptide', 'GeneID', 'GenBank_entry_mRNA', 'mut_freq', 'Mean', 'Median')


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
        geneID <- getBM(attributes = c("ensembl_gene_id", "external_gene_name"), 
                        filters = "external_gene_name", 
                        values = f5$Gene,
                        useCache = FALSE,
                        mart = old_mart)
        colnames(geneID) <- c('geneID', 'Gene')
        f5 <- merge(f5, geneID, by.x = 'Gene', by.y = 'Gene', all.x = TRUE)
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




mhc2.rna.select <- c('GENE', 'HLA', 'Peptide','Core', 'Affinity.nM.', 'X.Rank', 'BindingLevel_mut', 'Peptide.1','Core.1', 'Affinity.nM..1', 'X.Rank.1', 'BindingLevel_ref', 'NM_accessions', 'aaChange', 'sumReads', 'numOfBaseExp', 'dna_freAlt', 'dna_cov', 'freRef', 'freAlt', 'expAlt', 'TPM', 'FPKM')
mhc2.rna.rename <- c('Gene', 'MHC allele', 'Mutant peptide','9mer_core_mut', 'Aff.nM_mut', 'Rank_mut', 'BindLevel_mut', 'Wildtype peptide','9mer_core_wt', 'Aff.nM_wt', 'Rank_wt', 'BindLevel_wt', 'GenBank_entry_mRNA', 'aaChange', 'sumReads', 'numOfBaseExp', 'dna_freAlt', 'dna_cov', 'freRef', 'freAlt', 'expAlt', 'TPM', 'FPKM')
mhc2.rna.reorder <- c('Gene', 'MHC allele', 'Mutant peptide', 'aaChange', 'Epitope_length', 'Mut_pos_epitope','9mer_core_mut', 'Aff.nM_mut', 'Rank_mut', 'BindLevel_mut', 'Wildtype peptide','9mer_core_wt', 'Aff.nM_wt', 'Rank_wt', 'BindLevel_wt',  'WildType_long_peptide', 'Mutant_long_peptide', 'Epi_pos_in_longpep', 'geneID', 'GenBank_entry_mRNA', 'TPM', 'FPKM', 'sumReads', 'numOfBaseExp', 'dna_freAlt', 'dna_cov', 'freRef', 'freAlt', 'expAlt')

mhc2.tcga.select <- c('GENE', 'HLA', 'Peptide','Core', 'Affinity.nM.', 'X.Rank', 'BindingLevel_mut', 'Peptide.1','Core.1', 'Affinity.nM..1', 'X.Rank.1', 'BindingLevel_ref', 'NM_accessions', 'aaChange', 'mutFre', 'GeneID', 'Mean', 'Median')
mhc2.tcga.rename <- c('Gene', 'MHC allele', 'Mutant peptide', '9mer_core_mut', 'Aff.nM_mut', 'Rank_mut', 'BindLevel_mut', 'Wildtype peptide','9mer_core_wt', 'Aff.nM_wt', 'Rank_wt', 'BindLevel_wt', 'GenBank_entry_mRNA', 'aaChange', 'mut_freq', 'GeneID', 'Mean', 'Median')
mhc2.tcga.reorder <- c('Gene', 'MHC allele', 'aaChange', 'Epitope_length', 'Mut_pos_epitope', 'Mutant peptide','9mer_core_mut', 'Aff.nM_mut', 'Rank_mut', 'BindLevel_mut', 'Wildtype peptide','9mer_core_wt', 'Aff.nM_wt', 'Rank_wt', 'BindLevel_wt', 'mut_freq', 'WildType_long_peptide', 'Mutant_long_peptide', 'Epi_pos_in_longpep','GeneID', 'GenBank_entry_mRNA', 'Mean', 'Median')


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
        geneID <- getBM(attributes = c("ensembl_gene_id", "external_gene_name"), 
                        filters = "external_gene_name", 
                        useCache = FALSE,
                        values = f5$Gene,
                        mart = old_mart)
        colnames(geneID) <- c('geneID', 'Gene')
        f5 <- merge(f5, geneID, by.x = 'Gene', by.y = 'Gene', all.x = TRUE)
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
