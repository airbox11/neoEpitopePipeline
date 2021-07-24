all_in_one_pipeline.sh S2975Nr1_COAD S2975Nr1 JD52 No TCGA-COAD &


runID=S2975Nr1_COAD
sampleID=S2975Nr1
patientID=JD52
RNAseq=No
tcga=TCGA-COAD


all_in_one_pipeline.sh S2975Nr3 S2975Nr3 ZK55 No TCGA-PAAD &
runID=S2975Nr3
sampleID=S2975Nr3
patientID=ZK55
RNAseq=No
tcga=TCGA-PAAD
scriptsDir=/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline
workDir=/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline_collection/${runID}


all_in_one_pipeline.sh S3005Nr1 S3005Nr1 GO53 No TCGA-LIHC &
runID=S3005Nr1
sampleID=S3005Nr1
patientID=GO53
RNAseq=No
tcga=TCGA-LIHC
scriptsDir=/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline
workDir=/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline_collection/${runID}



all_in_one_pipeline.sh S2975Nr1_READ S2975Nr1 JD52 No TCGA-READ &


all_in_one_pipeline.sh S2975Nr3_DkmsHLA S2975Nr3 ZK55 No TCGA-PAAD &


runID=S2975Nr3_DkmsHLA
sampleID=S2975Nr3
patientID=ZK55
RNAseq=No
tcga=TCGA-PAAD
scriptsDir=/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline
workDir=/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline_collection/${runID}



all_in_one_pipeline.sh S3005Nr1_4 S3005Nr1 GO53 No TCGA-LIHC &
runID=S3005Nr1_4.1
sampleID=S3005Nr1
patientID=GO53
RNAseq=No
tcga=TCGA-LIHC
scriptsDir=/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline
workDir=/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline_collection/${runID}
mhcIversion=4.1


all_in_one_pipeline.sh S3005Nr1_4 S3005Nr1 GO53 No TCGA-LIHC &
sampleID=i034
workDir=/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline_collection/i034


############

all_in_one_pipeline.sh S2914Nr2 S2914Nr2 AbiH64 No TCGA-COAD 4.1 &
all_in_one_pipeline.sh S2914Nr4 S2914Nr4 MD63 Yes RNAseq 4.1 &
all_in_one_pipeline.sh S2975Nr1-COAD S2975Nr1 JD52 No TCGA-COAD 4.1 &
all_in_one_pipeline.sh S2975Nr1-READ S2975Nr1 JD52 No TCGA-READ 4.1 &
all_in_one_pipeline.sh S2975Nr3 S2975Nr3 ZK55 No TCGA-PAAD 4.1 &
all_in_one_pipeline.sh S2975Nr3-Dkms S2975Nr3 ZK55 No TCGA-PAAD 4.1 &
all_in_one_pipeline.sh S3005Nr1  S2914Nr1  GO53 No TCGA-LIHC 4.1 &

############
all_in_one_pipeline.sh S2914Nr2 S2914Nr2 AbiH64 No TCGA-COAD 4.1
runID=S2914Nr2
sampleID=S2914Nr2
patientID=AbiH64
RNAseq=No
tcga=TCGA-COAD
mhcIversion=4.1


all_in_one_pipeline.sh S2914Nr4 S2914Nr4 MD63 Yes RNAseq 4.1 &
runID=S2914Nr4
sampleID=S2914Nr4
patientID=MD63
RNAseq=Yes
tcga=RNAseq
mhcIversion=4.1


all_in_one_pipeline.sh S2914Nr4 S2914Nr4 MD63 Yes RNAseq 4.0 &
runID=S2914Nr4
sampleID=S2914Nr4
patientID=MD63
RNAseq=Yes
tcga=RNAseq
mhcIversion=4.0

############

all_in_one_pipeline.sh S2914Nr2 S2914Nr2 AbiH64 No TCGA-COAD 4.1 &
all_in_one_pipeline.sh S2914Nr4 S2914Nr4 MD63 Yes RNAseq 4.1 &

all_in_one_pipeline.sh S2975Nr1-COAD S2975Nr1 JD52 No TCGA-COAD 4.1 &

all_in_one_pipeline.sh S2975Nr1-READ S2975Nr1 JD52 No TCGA-READ 4.1 &
all_in_one_pipeline.sh S2975Nr3 S2975Nr3 ZK55 No TCGA-PAAD 4.1 &
all_in_one_pipeline.sh S2975Nr3-Dkms S2975Nr3 ZK55 No TCGA-PAAD 4.1 &

all_in_one_pipeline.sh S3005Nr1 S3005Nr1 GO53 No TCGA-LIHC 4.1 &

###  TRC

all_in_one_pipeline.sh trcpoc004HLA trcpoc004HLA trcpoc004HLA Yes RNAseq 4.1 &

all_in_one_pipeline.sh trcpoc004HLA trcpoc004HLA trcpoc004HLA Yes RNAseq 4.1 s4&


### buffy coat:
all_in_one_pipeline.sh bc01p bc01p bc01p No RNAseq 4.1 s1b&
all_in_one_pipeline.sh bc01p2 bc01p2 bc01p2 No RNAseq 4.1 s2s3s4 &
all_in_one_pipeline.sh bc01pr1_17 bc01pr1_17 bc01pr1_17 No RNAseq 4.1 s1.2&
all_in_one_pipeline.sh bc01pr1_18 bc01pr1_18 bc01pr1_18 No RNAseq 4.1 s1.2&


###
all_in_one_pipeline.sh bc01p2_low bc01p2_low bc01p2_low Yes RNAseq 4.1 s5.1s5.2 &
all_in_one_pipeline.sh bc01p2_upper bc01p2_upper bc01p2_upper Yes RNAseq 4.1 s5.1s5.2 &

all_in_one_pipeline.sh bc01p2_low bc01p2_low bc01p2_low Yes RNAseq 4.1 s3 &

## HLA for IPNCT_RW67, IPNCT_PW60 (s3217)
## indel 

all_in_one_pipeline.sh S3217Nr1 S3217Nr1 RW67 Yes RNAseq  4.1 s4d &
all_in_one_pipeline.sh S3217Nr3 S3217Nr3 PW60 Yes RNAseq  4.1 s4d &

all_in_one_pipeline.sh indel_test2 indel_test2 indel_test2 Yes RNAseq  4.1 s4c &


## 3228, IL85
all_in_one_pipeline.sh NR78 S3328Nr1 NR78 Yes RNAseq  4.1 s4as4bs4c &

all_in_one_pipeline.sh EB72 S3328Nr3 EB72 Yes RNAseq  4.1 s2s3s8as8b &
all_in_one_pipeline.sh EB72 S3328Nr3 EB72 Yes RNAseq  4.1 s4as4bs4c &

all_in_one_pipeline.sh IL85 IL85 IL85 No TCGA-CESC 4.1 s4d &

## indel xlsx test
all_in_one_pipeline.sh S2975Nr1-COAD S2975Nr1 JD52_yh Yes RNAseq  4.1 s8d &

## indel debug sequences
all_in_one_pipeline.sh S3217Nr3 S3217Nr3 PW60 Yes RNAseq  4.1 s4a &

## re-run indel for IL85 NR78 EB72
all_in_one_pipeline.sh IL85 IL85 IL85 No TCGA-CESC 4.1 s4as4bs4c &
all_in_one_pipeline.sh NR78 S3328Nr1 NR78 Yes RNAseq  4.1 s4as4bs4c &
all_in_one_pipeline.sh EB72 S3328Nr3 EB72 Yes RNAseq  4.1 s4as4bs4c &

## move results to omics
all_in_one_pipeline.sh S3217Nr1 S3217Nr1 RW67 Yes RNAseq  4.1 s4as4bs4c &
all_in_one_pipeline.sh S3217Nr3 S3217Nr3 PW60 Yes RNAseq  4.1 s4as4bs4c &

all_in_one_pipeline.sh S3005Nr1 S3005Nr1 GO53 No TCGA-LIHC 4.1 s8b &

all_in_one_pipeline.sh S2914Nr2 S2914Nr2 AbiH64 No TCGA-COAD 4.1 s8b &
all_in_one_pipeline.sh S2914Nr4 S2914Nr4 MD63 Yes RNAseq 4.1 s8b &
all_in_one_pipeline.sh S2975Nr1-COAD S2975Nr1 JD52 No TCGA-COAD 4.1 s8b &
all_in_one_pipeline.sh S2975Nr3-dkms S2975Nr3 ZK55 No TCGA-PAAD 4.1 s8b &

all_in_one_pipeline.sh trcpoc004 trcpoc004 trcpoc004 Yes RNAseq 4.1 s8b &

## indel debug2
# all_in_one_pipeline.sh S3217Nr1 S3217Nr1 RW67 Yes RNAseq 4.1 s4as4bs4c > S3217Nr1.tmp 2>&1  &
all_in_one_pipeline.sh S3217Nr3 S3217Nr3 PW60 Yes RNAseq 4.1 s4as4bs4c > PW60.tmp 2>&1  &
all_in_one_pipeline.sh NR78 S3328Nr1 NR78 Yes RNAseq 4.1 s4as4bs4c > NR78.tmp 2>&1  &
all_in_one_pipeline.sh EB72 S3328Nr3 EB72 Yes RNAseq 4.1 s4as4bs4c > EB72.tmp 2>&1  &
all_in_one_pipeline.sh IL85 IL85 IL85 No TCGA-CESC 4.1 s4as4bs4c > IL85.tmp 2>&1  &


## K26K-MK6UTZ
all_in_one_pipeline K26K-MK6UTZ 52656 HS80 Yes RNAseq 4.1a s1b
all_in_one_pipeline HS80 52656 HS80 Yes RNAseq 4.1 s2s3s8as8b
all_in_one_pipeline HS80 52656 HS80 Yes RNAseq 4.1 s4as4bs4c

## omics move ====
all_in_one_pipeline NR78 S3328Nr1 NR78 Yes RNAseq 4.1 s4cs8b 


## catch -dataset:
all_in_one_pipeline K26K-tumor 39032 K26K yes RNAseq 4.1 s1a &

all_in_one_pipeline K26K-HGXQVM sampleID K26K-HGXQVM Yes RNAseq 4.1 s2 &

## 141 debug

all_in_one_pipeline K26K-HGXQVM-metastasis22-01 sampleID K26K-HGXQVM-metastasis22-01 Yes RNAseq 4.1 s4a &
all_in_one_pipeline K26K-HGXQVM-tumor11 sampleID K26K-HGXQVM-tumor11 Yes RNAseq 4.1 s4a &

all_in_one_pipeline K26K-J1JGYX-metastasis11-01-p-buffy-coat1-01-p2 sampleID K26K-J1JGYX-metastasis11-01-p-buffy-coat1-01-p2 Yes RNAseq 4.1 s3 &

all_in_one_pipeline K26K-J1JGYX-metastasis2-01-p-buffy-coat1-01-p snv  Yes RNAseq 4.1 s4b 

## tcga 
all_in_one_pipeline K26K-HGXQVM-tumor11 sampleID K26K-HGXQVM-tumor11 No TCGA-BRCA 4.1 s3 &

all_in_one_pipeline K26K-HGXQVM-metastasis22-01 sampleID K26K-HGXQVM-metastasis22-01 No TCGA-BRCA 4.1 s3 &


##  HL50
all_in_one_pipeline HL50-3 sampleID HL50-3 No TCGA-BRCA s8b debug
all_in_one_pipeline HL50-4 sampleID HL50-3 No TCGA-BRCA s8b debug

all_in_one_pipeline K26K-MK6UTZ sampleID K26K-MK6UTZ No TCGA-BRCA s3s8as8b &
all_in_one_pipeline K26K-MK6UTZ sampleID K26K-MK6UTZ No TCGA-BRCA i4ai4bi4c &


## ts73
all_in_one_pipeline TS73 sampleID TS73 Yes RNAseq s2s3s8as8b &
all_in_one_pipeline LF89 sampleID LF89 Yes RNAseq s2s3s8as8b &


all_in_one_pipeline TS73 sampleID TS73 Yes RNAseq s8b &
all_in_one_pipeline LF89 sampleID LF89 Yes RNAseq s8b &


## IT01 vg53
all_in_one_pipeline IT01 sampleID IT01 No TCGA-THYM s1bs2s3s8as8bi4ai4bi4c
all_in_one_pipeline VG53 sampleID VG53 No TCGA-COAD s1bs2s3s8as8bi4ai4bi4c



## promise S014-1HBNPG
all_in_one_pipeline \
-r S014-1HBNPG \
-a sampleID \
-p S014-1HBNPG \
-n No \
-t RNAseq \
-s s1a \
-d debug \
-h 68_R 

all_in_one_pipeline -r S014-1HBNPG -a sampleID -p S014-1HBNPG -n No -t RNAseq -s s1a -h 68_R
all_in_one_pipeline -r S014-1HBNPG -a sampleID -p S014-1HBNPG -n No -t RNAseq -s s1a -h 69_R
all_in_one_pipeline -r S014-1HBNPG -a sampleID -p S014-1HBNPG -n No -t RNAseq -s s1a -h 70_R 
all_in_one_pipeline -r S014-1HBNPG -a sampleID -p S014-1HBNPG -n No -t RNAseq -s s1a -h 71_R 

## IT01 vg53

all_in_one_pipeline -r IT01 -a sampleID -p IT01 -n No -t TCGA-THYM -s i4c
all_in_one_pipeline -r VG53 -a sampleID -p VG53 -n No -t TCGA-COAD -s i4c


## 
all_in_one_pipeline -r S014-1HBNPG -a sampleID -p S014-1HBNPG -n No -t RNAseq -s s1a -h 68_R -d debug

all_in_one_pipeline -r S014-1HBNPG -a sampleID -p S014-1HBNPG -n No -t RNAseq -s s1a -h 68_R 


## K26K-BZC91B 
all_in_one_pipeline -r K26K-BZC91B -s s1a -h manual 
all_in_one_pipeline -r K26K-P7V4JK -s s0 


## HL50
all_in_one_pipeline -r HL50-3 -t TCGA-BRCA -s i4a -d debug
all_in_one_pipeline -r HL50-4 -t TCGA-BRCA -s s3s8as8b 


## stabpan:

all_in_one_pipeline -r EB72 -s s2 -d debug

all_in_one_pipeline -r EB72 -s s2 -e netMHCstabpan -d debug

all_in_one_pipeline -r EB72 -e netMHCstabpan -n Yes -t RNAseq  -s s3 -d debug
all_in_one_pipeline -r EB72 -e netMHCstabpan -s s3 -d debug


all_in_one_pipeline -r EB72 -e netMHCstabpan -t RNAseq  -s s8as8b
all_in_one_pipeline -r EB72 -e netMHCpan4_1  -t RNAseq  -s s8as8b


all_in_one_pipeline -r EB72 -e netMHCstabpan -s s8as8b
all_in_one_pipeline -r EB72 -e netMHCpan4_1  -s s8as8b






