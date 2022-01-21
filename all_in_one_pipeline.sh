#!/usr/bin/bash
set -e

function usage() { 
	echo "
	Usage: $0 runID netMHCpanID patientID tcga steps [debug]

	) -r: runID: 
	] -e: netMHCpanID:
		(both), netMHCpan4_1, netMHCstabpan
	] -p: patientID:
		($ runID)
	] -t: tcga: 
		(TCGA-READ), RNAseq
	) -s: steps: 
		s0: prepare folder
		s1a_HLA
		s1b_HLA

		s2_snv
		s3_add_expression
		s8a_filter
		s8b_xlsx_to_public
		snv: all steps

		i4a_indel_predict
		i4b_indel_tsv
		i4c_xlsx_to_public
		indel: all steps

		f1a: run_star_arriba , (f1b: run_arriba)
		f2: prepare_HLA
		f3: neo_prediction
		f4: mer21
		f5: to_xlsx
		fusion: all steps

	] -d: debug: 
		debug, empty
	] -h: hlaID
		(mhc), promise
	" 1>&2
	exit 1
	}

while getopts :r:e:p:t:s:d:h: opt; do
	case $opt in
		r)
			runID=${OPTARG}
			;;
		e)
			netMHCpanID=${OPTARG}
			;;
		p)
			patientID=${OPTARG}
			;;
		t)
			tcga=${OPTARG}
			;;
		s)
			steps=${OPTARG}
			;;
		d)
			debug=${OPTARG}
			;;
		h)
			hlaID=${OPTARG}
			;;
		a)
			dataType=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "${runID}" ]; then
	usage
fi

## default value 
if [ -z $netMHCpanID ]; then
	netMHCpanID=both
fi

if [ -z $steps ]; then
	steps=s0
fi

if [ -z $patientID ]; then
	patientID=$runID
fi

if [ -z $tcga ]; then
	tcga=TCGA-READ
fi

if [ -z $hlaID ]; then
	hlaID=mhc
fi

if [ -z $dataType ]; then
	dataType=RNAbamOpt
fi



# script=/icgc/dkfzlsdf/analysis/D120/yanhong/all_in_one_pipeline/all_in_one_pipeline_0.sh
script=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline/all_in_one_pipeline_0.sh


if [ -z $debug ]; then
	PID="${runID}-${hlaID}-${netMHCpanID}-${tcga}-${steps}"
	outputReport=/omics/groups/OE0422/internal/yanhong/all_in_one_pipeline_collection/mhc4.1/log/${PID}.log
	rm -f $outputReport
	env="all,runID=$runID,netMHCpanID=$netMHCpanID,patientID=$patientID,tcga=$tcga,steps=$steps,hlaID=$hlaID,dataType=$dataType"
	bsub -u y.lyu@dkfz-heidelberg.de -o $outputReport -r -R "rusage[mem=10G]" -J $PID -W 50:00 -env "$env" -n 6 $script
else
	echo debug now '>>>>>>>>.'

	export runID
	export netMHCpanID
	export patientID
	export tcga
	export steps
	export debug
	export hlaID
	export dataType

	bash $script 
fi