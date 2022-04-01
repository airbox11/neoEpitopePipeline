#!/usr/bin/env bash
set -e

module load perl/5.24.1
module load R/3.6.2
module load samtools/1.5

STAR=/home/lyuya/miniconda3/bin/STAR
arriba=/software/arriba/2.1.0/bin/arriba




## prepare data_manually ====
# hla fastq
# snv vcf, [bam, tsv, TCGA]
# indel vcf

## input parameters: ====
dir_work=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1

if [ $hlaID = promise ]; then

	tumorID=`echo $runID | cut -d _ -f 2`
	runID=`echo $runID | cut -d _ -f 1`

	if [ $tumorID == 'tumor1' -o $tumorID == 'tumor11' ];then
		stage=T1T2
	elif [ $tumorID == 'tumor12' ];then
		stage=T12
	elif [ $tumorID == 'tumor31' ];then
		stage=T2ERW
	elif [ $tumorID == 'tumor41' ];then
		stage=T3
	elif [ $tumorID == 'tumor51' ];then
		stage=T3ERW
	elif [ $tumorID == 'tumor61' ];then
		stage=T4
	fi

	dir_input=/omics/odcf/project/OE0422/promise/sequencing
	workDir=$dir_work/promise/output_datasets/${runID}_${stage}_${tumorID}
	outputDir=/omics/odcf/analysis/OE0422_projects/promise/results_per_pid_2/$runID

else
	dir_input=/omics/odcf/project/OE0422/immuno_patients_nct/sequencing
	workDir=$dir_work/${runID}
	outputDir=/omics/odcf/analysis/OE0422_projects/Immuno-Patients-NCT/sequencing/exon_sequencing/results_per_pid/$runID
fi


workDir9=$workDir/9_Fusion_gene_based_neoepitope_identification
workDir92=$workDir9/2_arriba_result_${dataType}
workDir93=$workDir9/3_neoPrediction_${dataType}
scriptsDir=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline

## functions ================================

## SNV BASED PREIDCTION ====
## 0) prepare folder ====




function prepare_folder () {
	echo $workDir
	# echo ${runID}_$tumorID
	# ls -l --color $workDir/8*
	# find $outputDir -type -f
	# # exit 0


	# dir_check=$outputDir/Epitope_prediction/snv_based/${stage}_${tumorID}
	# echo $dir_check
	# find $dir_check -type f | wc -l
	# # ls -l --color=auto $outputDir/*
	# exit 0

	mkdir -p $workDir
	mkdir -p $workDir/1_hla_type
	mkdir -p $workDir/2_SNVs_based_neoepitope_prediction
	mkdir -p $workDir/3_add_expression
	mkdir -p $workDir/4_indel_based_prediction
	mkdir -p $workDir/8_chose_neoepitode 
	mkdir -p $workDir/9_Fusion_gene_based_neoepitope_identification
	mkdir -p $workDir92

	mkdir -p $outputDir/Mutation_analysis/snv 
	mkdir -p $outputDir/Mutation_analysis/CGI 
	mkdir -p $outputDir/Mutation_analysis/indel 
	mkdir -p $outputDir/Epitope_prediction/snv_based 
	mkdir -p $outputDir/Epitope_prediction/indel_based 
	mkdir -p $outputDir/Epitope_prediction/fusion_genes 
	mkdir -p $outputDir/HLA/DKMS 
	mkdir -p $outputDir/HLA/In_silico 
	mkdir -p $outputDir/HLA/LOH
	mkdir -p $outputDir/Gene_Expression


	## creat link to mhc/runID:

	## rna input:

	if [ $hlaID = promise ]; then

		echo ${runID}_${tumorID}
		## prepare RNA bam file ======== ======== ========
		tumorID_2=${tumorID}-01
		dir_RNA=$dir_input/rna_sequencing/view-by-pid/${runID}/${tumorID_2}/paired/merged-alignment/.merging_0

		if [[ $tcga == 'RNAseq' ]]; then
			file1=`find $dir_RNA -name "*${runID}_merged.mdup.bam"| xargs -I {}  realpath {}`
			file2=`find $dir_RNA -name '*fpkm_tpm.featureCounts.tsv'| xargs -I {}  realpath {}`

			ln -sf $file1 $workDir/3_add_expression
			ln -sf $file2 $workDir/3_add_expression
		fi

		dir_wgs=$dir_input/whole_genome_sequencing/view-by-pid/${runID}
		## prepare WGS bam file for HLA-prediction ======== ======== ========
		tumorID_index=`echo $tumorID | sed 's/tumor//'`

		buffcoatID_1=buffy-coat${tumorID_index}-01
		buffcoatID_2=buffy-coat11-01

		if [ ! -d "${dir_wgs}/${buffcoatID_1}" ];then
			if [ -d "${dir_wgs}/$buffcoatID_2" ];then
				buffcoatID_1=$buffcoatID_2
			else
				ls -l
				read -p "Input Selection for buffy-coat for ${runID}_${tumorID}:" buffcoatID_1
			fi
		fi

		dir_wgs2=$dir_input/whole_genome_sequencing/view-by-pid/${runID}/$buffcoatID_1/paired/merged-alignment

		file1=`find $dir_wgs2 -maxdepth 1 -name '*merged.mdup.bam'`
		ln -sf $file1 $workDir/1_hla_type

		## snv, indel ======== ======== ========
		dir_snv=$dir_wgs/snv_results/paired/${tumorID_2}_${buffcoatID_1}
		file1=`find ${dir_snv} -name '*somatic_functional_snvs_conf_8_to_10.vcf'`
		ln -sf $file1 $workDir/2_SNVs_based_neoepitope_prediction

		dir_indel=$dir_wgs/indel_results/paired/${tumorID_2}_${buffcoatID_1}
		file1=`find ${dir_indel} -type f -name '*somatic_functional_indels_conf_8_to_10.vcf'`
		ln -sf $file1 $workDir/4_indel_based_prediction

		echo '>>>>>>>>>>>>>>> s0: prepare_folder: done'

	else
		dir_RNA=$dir_input/rna_sequencing/view-by-pid/IPNCT_${runID}
		if [ -d $dir_RNA ];then
			cd $dir_RNA
			input1=tumor
			if [ ! -d "$input1" ];then
				ls 
				read -p "Input Selection:" input1
			fi
			cd $input1/paired/merged-alignment/.merging_0
			file1=`find . -name "*${runID}_merged.mdup.bam"| xargs -I {}  realpath {}`
			file2=`find . -name '*fpkm_tpm.featureCounts.tsv'| xargs -I {}  realpath {}`

			ln -sf $file1 $workDir/3_add_expression
			ln -sf $file2 $workDir/3_add_expression
		fi

		## bam for HLA-prediction
		cd $dir_input/exon_sequencing/view-by-pid/IPNCT_${runID}
		input1=control
		if [ ! -d "$input1" ];then
			ls
			read -p "Input Selection:" input1
		fi
		cd $input1/paired/merged-alignment/.merging_0

		file1=`find . -name '*merged.mdup.bam'| xargs -I {}  realpath {}`
		ln -sf $file1 $workDir/1_hla_type

		## snv, indel
		cd $dir_input/exon_sequencing/view-by-pid/IPNCT_${runID}

		input1=snv_results
		file1=`find . -name '*somatic_functional_snvs_conf_8_to_10.vcf'| xargs -I {}  realpath {}`
		ln -sf $file1 $workDir/2_SNVs_based_neoepitope_prediction
		# ls -tl $workDir/2_SNVs_based_neoepitope_prediction

		input1=indel_results
		file1=`find . -name '*somatic_functional_indels_conf_8_to_10.vcf'| xargs -I {}  realpath {}`
		ln -sf $file1 $workDir/4_indel_based_prediction
		# ls -tl $workDir/4_indel_based_prediction


		echo $workDir
		echo '>>>>>>>>>>>>>>> s0: prepare_folder: done'
	fi
	echo $workDir
	ls -l --color=auto $workDir/*

	## for CGI Mutation_analysis
	rm -rf $workDir/1_hla_type/mutation.csv
	find $workDir -name '*vcf' | xargs -I {} awk '(NR>1) { print $1, $2, $4, $5 }' {} >> $workDir/1_hla_type/mutation.csv
	cp $workDir/1_hla_type/mutation.csv $outputDir/Mutation_analysis/CGI 

}


function rename_zip {
	zipDir=$outputDir/zip
	# rm -fr ${runID}.zip
	rm -fr $outputDir/*.zip
	rm -fr $zipDir
	rsync -a $outputDir $zipDir 2>&1 > /dev/null


	IFS=$'\n'
	files=($(find $zipDir -type f))
	unset IFS
	for i in ${files[*]}
	do
		mv $i `echo $i | sed "s;^\(.*/\)\([^/]\+\)$;\1${runID}_\2;"` 
	done

	cd $zipDir/$runID
	zip -r $outputDir/${runID}.zip *
	cd -

	rm -fr $zipDir
	echo '>>>>>>>>>>>>>>> change name: done ]]]]]]]]]]]]]]]]]'
	echo $outputDir
	ls -l --color $outputDir
}

## 1) HLA typing prediction ====
function s1a_HLA () {
	phlat_dir=${workDir}/1_hla_type/hla_${hlaID}
	rm -rf $phlat_dir
	mkdir -p $phlat_dir


	if [ $hlaID = 'promise' ]; then
		sourceDir=/omics/odcf/project/OE0422/promise/sequencing/whole_genome_sequencing/view-by-pid/$runID/buffy-coat*/paired/run*/sequence/

	elif [ $hlaID = 'phlat_all' ]; then
		sourceDir=$workDir/1_hla_type
	fi
	fq1=${workDir}/1_hla_type/fq1.fastq.gz
	fq2=${workDir}/1_hla_type/fq2.fastq.gz

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

	# rm -f ${workDir}/1_hla_type/fq*.fastq.gz

	## format hla ====
	input=${workDir}/1_hla_type/phlat_$hlaID/*_HLA.sum
	output=${workDir}/1_hla_type/format_hla
	script=/omics/groups/OE0422/internal/scripts/HLA_typing/run_format_phlat.sh
	sh $script -p $input -o $output


}


function s1b_hla_sab () {
	PID=hla_sab_$runID

	workDirHla=$workDir/1_hla_type
	scriptDir=/omics/groups/OE0422/internal/yanhong/git/neoepitope_prediction-master_gitlab/neoepitope_prediction
	script=$scriptDir/Immunopipe.sh
	referenceDir=$scriptDir/data


	if [ $hlaID = 'promise' ]; then
		sourceDir=/omics/odcf/project/OE0422/promise/sequencing/whole_genome_sequencing/view-by-pid/$runID/buffy-coat*/paired/merged-alignment
	else
		sourceDir=$workDir/1_hla_type
	fi


	## fing format_hla if exist, otherwise run hla-prediction
	if [[ -f ${workDirHla}/format_hla ]];then
		return 0
	else 
		format_hla=`find ${outputDir}/HLA -type f -name 'format_hla'`
		echo $format_hla

		if [[ -f $format_hla ]]; then
			ln -fs $format_hla $workDir/1_hla_type
		else
			bam=`ls $sourceDir | grep -P '^(?!.*chimeric).*mdup.bam$'| xargs -I {} echo $sourceDir/{}`
			bam=`realpath $bam`

			## check if hla preidiction completed or not, fodler_check=$workDir/1_hla_type/hla_sab_${runID}

			hlaFile=`find -L $workDir/1_hla_type -name '*.result_formatted.tsv'`
			if [ -z $hlaFile ];then
				echo " >>>>>>>>>>> >>>>>>>>>>> HLA prediction start"
				$script --control-dna-bam $bam --references $referenceDir --output $workDirHla --pid $PID --hla hla
			fi
			less $hlaFile | sed -E 's/^([ABC].*)\t(.*)/HLA-\1\2/g' | sed -E 's/^(D.*)\t(.*):(.*)/\1_\2\3/g' > $workDir/1_hla_type/format_hla
			if [ $hlaID != 'promise' ]; then
				cp $workDir/1_hla_type/format_hla $outputDir/HLA/In_silico
			fi
			echo ' >>>>>>>>>>> >>>>>>>>>>> s1b: hla type: done'
		fi
	fi


}




## 2) neoepitode predition with snv calling result ====



function s2_snv () {
	if [ $hlaID = 'promise' ]; then
		vcf=`find /omics/odcf/project/OE0422/promise/sequencing/whole_genome_sequencing/view-by-pid/$runID -name "snv*somatic_functional_snvs_conf_8_to_10.vcf" | grep ${tumorID}-`
		format_hla=`find $outputDir -name "format_hla" | xargs realpath`
		ln -fs $vcf $workDir/2_SNVs_based_neoepitope_prediction
		ln -fs $vcf $outputDir/Mutation_analysis/snv/$stage_$tumorID
		if [ ! -f ${workDir}/1_hla_type/format_hla ]; then
			ln -fs $format_hla ${workDir}/1_hla_type/format_hla
		fi
	fi

	vcf=${workDir}/2_SNVs_based_neoepitope_prediction/*.vcf
	# module load python/2.7.9
	# script=/omics/groups/OE0422/internal/yanhong/update_netMHCpan/netMHCpan_4.1/main_run_neoepitope_snvs.sh
	script=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline/update_netMHCpan/netMHCpan_4.1/main_run_neoepitope_snvs.sh
	format_hla=${workDir}/1_hla_type/format_hla


	sh $script \
	-i ${netMHCpanID} \
	-v $vcf \
	-m $format_hla \
	-o ${workDir}/2_SNVs_based_neoepitope_prediction/${netMHCpanID}

	echo '>>>>>>>>>>>>>>> s2: snv prediction: done'

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

		if [ $hlaID = 'promise' ]; then
			# RNA_chimeric_bam=`find $rnaDir -type f -name  'tumor*_chimeric_merged.mdup.bam' -printf "%T@\t%Tc %6k KiB %p\n" | sort -n | awk '{print $NF}' | tail -1`
			# RNA_chimeric_bam=`find $rnaDir -type f -name  'tumor*_chimeric_merged.mdup.bam' | grep ${tumorID}-`
			# dirSource=`realpath  $RNA_chimeric_bam | xargs dirname `

			rnaDir=/omics/odcf/project/OE0422/promise/sequencing/rna_sequencing/view-by-pid/$runID/$tumorID-*
			RNA_bam=`find $rnaDir -name '*merged.mdup.bam'  | grep -P '^(?!.*chimeric).*merged.mdup.bam$'`
			expression=`find $rnaDir -name '*.fpkm_tpm.featureCounts.tsv'`

			ln -fs $expression $workDir/3_add_expression
			ln -fs $RNA_bam $workDir/3_add_expression
		fi
		RNA_bam=`ls ${workDir}/3_add_expression | grep -P '^(?!.*chimeric).*mdup.bam$'| xargs -I {} echo ${workDir}/3_add_expression/{}`
		expression=${workDir}/3_add_expression/*.tsv

		sh $script -p $pipelineDir -v $vcf -b $RNA_bam -e $expression -n $inputMHCI -o $outputMHCI
		sh $script -p $pipelineDir -v $vcf -b $RNA_bam -e $expression -n $inputMHCII -o $outputMHCII 

		script=$scriptsDir/check_wish_list_genes.r
		outputFile=$workDir/8_chose_neoepitode/wish_list_genes_expression.csv
		Rscript $script $expression $outputFile
		cp $outputFile $outputDir/Gene_Expression

	else
		code=/omics/groups/OE0422/internal/scripts/add_expression/run_add_refExpression.R
		tcgaFile=/omics/groups/OE0422/internal/tcga_fpkm/${tcga}/${tcga}_expression_addName.tab

		Rscript $code $tcgaFile $inputMHCI $outputMHCI 
		Rscript $code $tcgaFile $inputMHCII $outputMHCII 
	fi

	echo '>>>>>>>>>>>>>>> s3: add RNA expression level: done'

}

function s8a_filter () {
	script=$scriptsDir/8a_filter_neoepitode.r
	Rscript $script $netMHCpanID $workDir $tcga

	## rename columns ==== ==== 
	cd $workDir/8_chose_neoepitode
	IFS=$'\n'
	files=($(find . -maxdepth 1 -name '*tab'))
	unset IFS
	for i in ${files[*]}
	do
		awk 'BEGIN{FS='\t'; OFS='\t'}{if (NR == 1) {gsub(" +","_",$0)}; print $0}' $i > ${i}_renameCol
	done
	cd -
	echo '>>>>>>>>>>>>>>> s8a: filter: done'
}


function s8b_xlsx_to_public (){
	if [ $hlaID = 'promise' ]; then
		outputDir_snv=${outputDir}/Epitope_prediction/snv_based/${stage}_${tumorID}
	else
		outputDir_snv=${outputDir}/Epitope_prediction/snv_based
	fi
	mkdir -p $outputDir_snv
	/tbi/software/x86_64/R/R-3.4.0/el7/bin/Rscript ${scriptsDir}/convert_to_xlsx.r $workDir $outputDir_snv snv
	echo '>>>>>>>>>>>>>>> s8b: xlsx: done'
}


## INDEL BASED PREIDCTION ====

function i4a_indel_predict () {

	if [ $hlaID = 'promise' ]; then
		indel_source_dir=/omics/odcf/project/OE0422/promise/sequencing/whole_genome_sequencing/view-by-pid/$runID/indel_results/paired/$tumorID-*
		vcf=`find $indel_source_dir -name 'indel*somatic_functional_indels_conf_8_to_10.vcf'| xargs realpath`
		ln -fs $vcf $workDir/4_indel_based_prediction

		indel_vcf_dir=$outputDir/Mutation_analysis/indel/$stage_$tumorID
		mkdir -p $indel_vcf_dir
		ln -fs $vcf $indel_vcf_dir
	fi

	vcf=${workDir}/4_indel_based_prediction/*vcf
	if [ ! -e ${workDir}/4_indel_based_prediction/*vcf ]; then
		echo "indel vcf file not exist!! >>>>> "
		exit 1
	fi

	indel_result=$workDir/4_indel_based_prediction/result
	mkdir -p $indel_result

	script=/omics/groups/OE0422/internal/scripts/neoepitope_indels/main_indels.sh
	hla=$workDir/1_hla_type/format_hla
	hla=${workDir}/1_hla_type/format_hla

	sh $script -f $vcf -l 21 -a $hla -o $indel_result
	echo '>>>>>>>>>>>>>>> i4a: prediction: done'
}


function i4b_indel_tsv () {
	script=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline/4b_indel_table.r
	Rscript $script $workDir
	echo '>>>>>>>>>>>>>>> i4b: filter: done'

}


function i4c_xlsx_to_public () {

	if [ $hlaID = 'promise' ]; then
		outputDir_indel=${outputDir}/Epitope_prediction/indel_based/${stage}_${tumorID}
	else
		outputDir_indel=${outputDir}/Epitope_prediction/indel_based
	fi

	mkdir -p $outputDir_indel

	/tbi/software/x86_64/R/R-3.4.0/el7/bin/Rscript ${scriptsDir}/convert_to_xlsx.r $workDir $outputDir_indel indel
	echo '>>>>>>>>>>>>>>> i4c: xlsx: done'
}

## fusion BASED PREIDCTION ====
## step 1 ====

function f1a_run_star_arriba () {
	bam=$workDir/3.2_add_local_rna/*merged.mdup.bam
	dirSource=`realpath  $bam | xargs dirname `


	fq1n=`find $dirSource -name '*1.fastq.gz'| wc -l `
	fq2n=`find $dirSource -name '*2.fastq.gz'| wc -l `
	if [ $fq1n -ne 1 ] || [ $fq2n -ne 1 ]; then
		echo '>>>>>>>>>>>>>>>  >>>>>>>>>>>>>>> >>>>>>>>>>>>>>> 1/2-fastq.gz for STAR is not unique!!'
		exit 0
	fi


	READ1=`find $dirSource -name '*1.fastq.gz' | head -1`
	READ2=`find $dirSource -name '*2.fastq.gz' | head -1`
	echo $READ1
	echo $READ2


	STAR_INDEX_DIR=/omics/groups/OE0422/internal/yanhong/git/arriba/STAR_index_GRCh37_ENSEMBL87
	annotation=/omics/groups/OE0422/internal/yanhong/git/arriba/ENSEMBL87.gtf
	assembly=/omics/groups/OE0422/internal/yanhong/git/arriba/GRCh37.fa


	cd $workDir92

	# READ1=`find ../3.2* -name '*fastq.gz' | xargs -I {} echo $workDir92/{}| grep -P  '^(?!.*?RNA).*fastq.gz' | grep -P 'R1' | tr '\n' ',' | sed 's/,$/\n/'`
	# READ2=`find ../1_prepare_fastq -name '*fastq.gz' | xargs -I {} echo $workDir92/{}| grep -P  '^(?!.*?RNA).*fastq.gz' | grep -P 'R2' | tr '\n' ',' | sed 's/,$/\n/'`
	$STAR \
		--runThreadN 8 \
		--genomeDir "$STAR_INDEX_DIR" --genomeLoad NoSharedMemory \
		--readFilesIn "$READ1" "$READ2" \
		--readFilesCommand zcat \
		--outStd BAM_Unsorted --outSAMtype BAM Unsorted --outSAMunmapped Within --outBAMcompression 0 \
		--outFilterMultimapNmax 50 --peOverlapNbasesMin 10 --alignSplicedMateMapLminOverLmate 0.5 --alignSJstitchMismatchNmax 5 -1 5 5 \
		--chimSegmentMin 10 --chimOutType WithinBAM HardClip --chimJunctionOverhangMin 10 --chimScoreDropMax 30 --chimScoreJunctionNonGTAG 0 --chimScoreSeparation 1 --chimSegmentReadGapMax 3 --chimMultimapNmax 50 |
	tee Aligned.out.bam |
	$samtools view -h |
	$arriba -x /dev/stdin  \
	-f blacklist \
	-g $annotation -a $assembly \
	-o $workDir92/fusions.tsv -O $workDir92/fusions.discarded.tsv 

	echo '>>>>>>>>>>>>>>>  >>>>>>>>>>>>>>> s1a: run_star_arriba : done'
}


function f1b_run_arriba () {

	if [ $hlaID = 'promise' ]; then
		rnaDir=/omics/odcf/project/OE0422/promise/sequencing/rna_sequencing/view-by-pid/$runID/$tumorID-*/paired/merged-alignment/.merging_0
		RNA_bam=`find $rnaDir -name '*merged.mdup.bam'  | grep -P '^(?!.*chimeric).*merged.mdup.bam$'`
		RNA_chimeric_bam=`find $rnaDir -name '*chimeric_merged.mdup.bam'`
	else
		bam=`ls ${workDir}/3_add_expression | grep -P '^(?!.*chimeric).*mdup.bam$'| xargs -I {} echo ${workDir}/3_add_expression/{}`
		dirSource=`realpath  $bam | xargs dirname `
		RNA_chimeric_bam=`find $dirSource -name '*chimeric_merged.mdup.bam'`
		RNA_bam=`find $dirSource -maxdepth 1 -name '*merged.mdup.bam'  | grep -P '^(?!.*chimeric).*merged.mdup.bam$'`
	fi

	sourceDir=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline/fusion_arriba/arriba_reference_hg19
	blacklist=$sourceDir/blacklist_hg19_hs37d5_GRCh37_v2.1.0.tsv.gz
	knowFusion=$sourceDir/known_fusions_hg19_hs37d5_GRCh37_v2.1.0.tsv.gz
	proteinDomain=$sourceDir/protein_domains_hg19_hs37d5_GRCh37_v2.1.0.gff3
	gtf=$sourceDir/gencode.v19.annotation_plain.gtf
	fa=$sourceDir/hs37d5_PhiX.fa

	if [ -z $RNA_chimeric_bam ]; then
		echo '>>>>>>>>   >>>>>>>>   >>>>>>>> RNA_chimeric_bam needed.'
		exit 0
	fi

	if [ -f $RNA_bam ]; then
		echo '>>>>>>>>   >>>>>>>>   >>>>>>>> satisfied: RNA_chimeric_bam'
		ls -l  $RNA_chimeric_bam
		echo '>>>>>>>>   >>>>>>>>   >>>>>>>> satisfied: RNA_bam'
		ls -l  $RNA_bam
		$arriba \
			-c $RNA_chimeric_bam \
			-x $RNA_bam \
			-b $blacklist \
			-k $knowFusion \
			-t $knowFusion \
			-p $proteinDomain \
			-g $gtf \
			-a $fa \
			-o $workDir92/fusions.tsv \
			-O $workDir92/fusions.discarded.tsv 
	fi
	echo '>>>>>>>>>>>>>>>  >>>>>>>>>>>>>>> f1b: run_arriba: done'
}



## step 2: ====
function f2_prepare_HLA () {
	script=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline/fusion_arriba/prepare_HLA.r
	Rscript $script $workDir $workDir92
	echo '>>>>>>>>>>>>>>>  >>>>>>>>>>>>>>> f2: prepare_HLA: done'
}

## step 3: ====

function f3_neo_prediction () {
	PID=${runID}_neoPrediction
	OUT_FUSION=$workDir9/3_neoPrediction_$dataType

	script=/omics/groups/OE0422/internal/yanhong/git/neoepitope_prediction-master1/Immunopipe.sh
	bam=$workDir92/Aligned.out.bam # not neccessary for fusion
	fusions_tsv=$workDir92/fusions.tsv

	$script --dna-bam $bam --fusions $fusions_tsv --fusion-confidence "medium high" --output $workDir92 --OUT_FUSION $OUT_FUSION --pid $PID
	## wait for bsub completed.
	file_wait=${workDir93}/fusion_mhc_tsv_done.log
	# while [ ! -f ${file_wait} ]
	# do
	# 	echo '--> fusion-based neoepitode predition: processing...'
	# 	sleep 30 # or less like 0.2
	# done
	echo '>>>>>>>>>>>>>>>  >>>>>>>>>>>>>>> f3: neo_prediction: done'
}

## step 4:
function f4_mer21 () {
	script=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline/fusion_arriba/mer21.r
	Rscript $script $workDir93
	echo '>>>>>>>>>>>>>>>  >>>>>>>>>>>>>>> f4: mer21: done'
}


## step 5: ====
function f5_to_xlsx () {
	script=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline/fusion_arriba/convert_to_xlsx_arribaFusion.r

	if [ $hlaID = promise ]; then
		outputDir_fusion=$outputDir/Epitope_prediction/fusion_genes/${stage}_${tumorID}/
	else
		outputDir_fusion=$outputDir/Epitope_prediction/fusion_genes
	fi

	/tbi/software/x86_64/R/R-3.4.0/el7/bin/Rscript $script $workDir $outputDir_fusion $dataType
	echo '>>>>>>>>>>>>>>>  >>>>>>>>>>>>>>> f5: to_xlsx: done'
}



## EXCUTION ====

## prepare_folder ==== ====

if echo $steps | grep -o s0; then
	prepare_folder
fi


## format_hla  ==== ====

if echo $steps | grep -o s1a; then
	s1a_HLA
fi

if echo $steps | grep -o s1b; then
	s1b_hla_sab
fi

## snv ==== ====

if echo $steps | grep -o s2; then
	if [ $netMHCpanID = 'both' ]; then
		netMHCpanID=netMHCpan4_1
		s2_snv
		netMHCpanID=netMHCstabpan
		s2_snv
	else
		s2_snv
	fi
fi

if echo $steps | grep -o s3; then
	s3_rna
fi

if echo $steps | grep -o s8a; then
	s8a_filter
fi


### indel ==== ====

if echo $steps | grep -o i4a; then
	i4a_indel_predict
fi

if echo $steps | grep -o i4b; then
	i4b_indel_tsv
fi


## fusion ==== ====

if echo $steps | grep -o f1a; then
	f1a_run_star_arriba
fi

if echo $steps | grep -o f1b; then
	f1b_run_arriba
fi

if echo $steps | grep -o f2; then
	f2_prepare_HLA
fi

if echo $steps | grep -o f3; then
	f3_neo_prediction
fi

if echo $steps | grep -o f4; then
	f4_mer21
fi

## snv, indel, fusion  ==== ====

if echo $steps | grep -o snv; then
	if [ $netMHCpanID = 'both' ]; then
		netMHCpanID=netMHCpan4_1
		s2_snv
		netMHCpanID=netMHCstabpan
		s2_snv
	else
		s2_snv
	fi
	s3_rna
	s8a_filter
fi

if echo $steps | grep -o indel; then
	i4a_indel_predict
	i4b_indel_tsv
fi

if echo $steps | grep -o fusion; then
	f1b_run_arriba
	f2_prepare_HLA
	f3_neo_prediction
	f4_mer21
fi


## lohhla ==== ====

if echo $steps | grep -o loh; then
	## run LOH ==== ==== 
	bash ${scriptsDir}/loh_hla.sh $workDir $runID $tumorID

	## merge with mhc results ==== ====
	mhc_input=`find $workDir/8_chose_neoepitode -name 'MHCI_*renameCol' | xargs basename`
	Rscript ${scriptsDir}/add_loh.r $workDir $mhc_input


	## copy files to final /HLA/LOH ==== ====
	if [ $hlaID = 'promise' ]; then
		outputDir_loh=$outputDir/HLA/LOH/${stage}_${tumorID}
	else
		outputDir_loh=$outputDir/HLA/LOH
	fi
	echo $outputDir_loh
	mkdir -p $outputDir_loh
	cp $workDir/5_LOHHLA/example-out/*xls $workDir/5_LOHHLA/example-out/Figures/*pdf $outputDir_loh
	ls -l --color $outputDir_loh
fi


## blast score ==== ==== 

if echo $steps | grep -o blst; then
	mhc_input=`find $workDir/8_chose_neoepitode -name 'MHCI_*loh' | xargs basename`
	bash $scriptsDir/blast_score.sh $workDir $mhc_input
	Rscript $scriptsDir/blast_score_mergeTable.r $workDir $mhc_input
fi

## align BLOSUM62 score ==== ==== 
if echo $steps | grep -o abls; then
	mhc_input=`find $workDir/8_chose_neoepitode -name 'MHCI_*loh' | xargs basename`
	Rscript $scriptsDir/align_BL62_score.r $workDir $mhc_input
fi

## xlsx ==== ====
if echo $steps | grep -o xlsx; then
	s8b_xlsx_to_public
	i4c_xlsx_to_public
	f5_to_xlsx
fi

## change name , zip ==== ====
if echo $steps | grep -o nz; then
	rename_zip
fi