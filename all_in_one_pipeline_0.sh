#!/usr/bin/bash
set -e  

module load perl/5.24.1
module load R/3.6.2
module load python/2.7.9
module load samtools/1.5



## prepare data_manually ====
# hla fastq
# snv vcf, [bam, tsv, TCGA]
# indel vcf



## input parameters: ====

if [ $hlaID = promise ]; then
	workDir=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/promise/output_datasets/${runID}
else
	workDir=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/${runID}
fi
scriptsDir=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline

## functions ================================

## SNV BASED PREIDCTION ====
## 0) prepare folder ====
function prepare_folder () {
	echo '>>>>>>>>>>> prepare_folder'
	mkdir -p $workDir
	mkdir -p $workDir/1.1_hla_typing
	mkdir -p $workDir/1.2_format_hla_result
	mkdir -p $workDir/2_SNVs_based_neoepitope_prediction
	mkdir -p $workDir/3_add_expression
	mkdir -p $workDir/4_indel_based_prediction
	mkdir -p $workDir/8_chose_neoepitode 
	mkdir -p $workDir/9_Fusion_gene_based_neoepitope_identification

	echo $workDir
}

## 1.1) HLA typing prediction ====
function s1a_HLA () {
	phlat_dir=${workDir}/1.1_hla_typing/phlat_${hlaID}
	rm -r $phlat_dir
	mkdir -p $phlat_dir


	if [ $hlaID = promise ]; then
		sourceDir=/icgc/dkfzlsdf/project/OE0422/promise/sequencing/whole_genome_sequencing/view-by-pid/$runID/buffy-coat*/paired/run*/sequence/

	elif [ $hlaID = manual ]; then
		sourceDir=$workDir/1.1_hla_typing
	fi


	fq1=${workDir}/1.1_hla_typing/fq1.fastq.gz
	fq2=${workDir}/1.1_hla_typing/fq2.fastq.gz

	if [ ! -f $fq1 ] || [ ! -f $fq2 ]; then
		f1=`find $sourceDir -name '*R1.fastq.gz' | sort | sed 's:\n: :g'`
		f2=`find $sourceDir -name '*R2.fastq.gz' | sort | sed 's:\n: :g'`

		if [ -z $f1 ] || [ -z $f2 ]; then
			echo '>>>>>>>>>>> >>>>>>>>>>> no fastq files found to dump together'
			exit 1
		fi

		cat $f1 > $fq1 &
		cat $f2 > $fq2 &
		wait 
	fi

	phlatRelease=/icgc/dkfzlsdf/analysis/G200/immuno/tools/phlat-release
	bowtie2=/software/bowtie2/2.3.5.1/bowtie2 
	threads=16
	python -O $phlatRelease/dist/PHLAT.py -1 $fq1  -2 $fq2 -index $phlatRelease/b2folder -b2url ${bowtie2} -tag "phlat_$hlaID" -e $phlatRelease -o ${phlat_dir} -p ${threads}

	# rm -f ${workDir}/1.1_hla_typing/fq*.fastq.gz

}

## 1.2) HLA typing format ====
function s1b_HLA () {

	input=${workDir}/1.1_hla_typing/phlat_$hlaID/*_HLA.sum
	output=${workDir}/1.2_format_hla_result/format_hla_phlat
	script=/omics/groups/OE0422/internal/scripts/HLA_typing/run_format_phlat.sh
	sh $script -p $input -o $output


}



## 2) neoepitode predition with snv calling result ====
function s2_snv () {
	mkdir -p ${workDir}/2_SNVs_based_neoepitope_prediction/result
	script=/omics/groups/OE0422/internal/yanhong/update_netMHCpan/netMHCpan_4.1/main_run_neoepitope_snvs.sh

	sh $script \
	-i ${netMHCpanID} \
	-v ${workDir}/2_SNVs_based_neoepitope_prediction/*.vcf \
	-m ${workDir}/1.2_format_hla_result/format_hla_phlat \
	-o ${workDir}/2_SNVs_based_neoepitope_prediction/$netMHCpanID
}


## 3) If RNA-seq exist, excute 3.2, otherwise excute 3.1 ====
function s3_rna () {
		inputMHCI=${workDir}/2_SNVs_based_neoepitope_prediction/$netMHCpanID/results_MHCI_epitopes.tab
		inputMHCII=${workDir}/2_SNVs_based_neoepitope_prediction/$netMHCpanID/results_MHCII_epitopes.tab
		outputMHCI=${workDir}/3_add_expression/MHCI_epitopes_${tcga}_$netMHCpanID.tab
		outputMHCII=${workDir}/3_add_expression/MHCII_epitopes_${tcga}.tab

	if [[ $tcga == 'RNAseq' ]];then
		script=/omics/groups/OE0422/internal/scripts/add_expression/main_add_RNA.sh
		pipelineDir=/omics/groups/OE0422/internal/scripts/add_expression
		vcf=${workDir}/2_SNVs_based_neoepitope_prediction/*.vcf

		bam=`ls ${workDir}/2_SNVs_based_neoepitope_prediction | grep -P '^(?!.*chimeric).*mdup.bam$'| xargs -I {} echo ${workDir}/2_SNVs_based_neoepitope_prediction/{}`
		expression=${workDir}/2_SNVs_based_neoepitope_prediction/*.tsv

		sh $script -p $pipelineDir -v $vcf -b $bam -e $expression -n $inputMHCI -o $outputMHCI 
		sh $script -p $pipelineDir -v $vcf -b $bam -e $expression -n $inputMHCII -o $outputMHCII 

	else
		code=/omics/groups/OE0422/internal/scripts/add_expression/run_add_refExpression.R
		tcgaFile=/omics/groups/OE0422/internal/tcga_fpkm/${tcga}/${tcga}_expression_addName.tab 

		Rscript $code $tcgaFile $inputMHCI $outputMHCI 
		Rscript $code $tcgaFile $inputMHCII $outputMHCII 
	fi

}

function s8a_filter () {
	script=$scriptsDir/8a_filter_neoepitode.r
	Rscript $script $netMHCpanID $workDir $tcga
}


function s8b_xlsx_to_public (){
	Rscript ${scriptsDir}/convert_to_xlsx.r $workDir ${patientID} snv 
}


## INDEL BASED PREIDCTION ====

function i4a_indel_predict () {
	if [ ! -e ${workDir}/4_indel_based_prediction/*vcf ]; then
		echo "indel vcf file not exist!! >>>>> "
		exit 1
	fi

	outputDir=$workDir/4_indel_based_prediction/result
	rm -rf $outputDir
	mkdir -p $outputDir

	script=/omics/groups/OE0422/internal/scripts/neoepitope_indels/main_indels.sh
	hla=$workDir/1.2_format_hla_result/format_hla_phlat
	
	sh $script -f ${workDir}/4_indel_based_prediction/*vcf -l 21 -a $hla -o $outputDir
}


function i4b_indel_tsv () {
	script=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline/4b_indel_table.r
	Rscript $script $runID

}


function i4c_xlsx_to_public  () {
	Rscript ${scriptsDir}/convert_to_xlsx.r $workDir ${patientID} indel

}



## EXCUTION ====

prepare_folder

if echo $steps | grep -o s0; then
	prepare_folder
	echo '>>>>>>>>>>>>>>> prepare_folder: done'

fi

if echo $steps | grep -o s1a; then
	s1a_HLA
	echo '>>>>>>>>>>>>>>> done'

fi

if echo $steps | grep -o s1b; then
	s1b_HLA
	echo '>>>>>>>>>>>>>>> done'
fi

if echo $steps | grep -o s2; then
	s2_snv
	echo '>>>>>>>>>>>>>>> done'
fi

if echo $steps | grep -o s3; then
	s3_rna
	echo '>>>>>>>>>>>>>>> done'
fi

if echo $steps | grep -o s8a; then
	s8a_filter
	echo '>>>>>>>>>>>>>>> done'
fi

if echo $steps | grep -o s8b; then
	s8b_xlsx_to_public
	echo '>>>>>>>>>>>>>>> done'
fi

if echo $steps | grep -o i4a; then
	i4a_indel_predict
	echo '>>>>>>>>>>>>>>> done'
fi

echo $steps
if echo $steps | grep -o i4b; then
	i4b_indel_tsv
	echo '>>>>>>>>>>>>>>> done'
fi

if echo $steps | grep -o i4c; then
	i4c_xlsx_to_public
	echo '>>>>>>>>>>>>>>> done'
fi