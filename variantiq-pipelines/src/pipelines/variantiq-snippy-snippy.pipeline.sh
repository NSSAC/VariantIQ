#!/usr/bin/env bash
set -e

echo "VariantIQ Snippy Pipeline"
PIPELINE_NAME="variantiq-snippy-snippy"
SAMPLE_FOLDER=$1
SINGLE_END=$2
DEBUG=$3
REFERENCE_GENOME=${SAMPLE_FOLDER}/reference_genome.fasta
READ1=${SAMPLE_FOLDER}/read_1.fastq
READ2=${SAMPLE_FOLDER}/read_2.fastq
TRUTH_GENOME=${SAMPLE_FOLDER}/truth_genome.fasta
BUILD_FOLDER=${SAMPLE_FOLDER}/_${PIPELINE_NAME}
PATH=$PATH:./pipelines:./pipelines/aligners

if [ ! -f "${SAMPLE_FOLDER}/${PIPELINE_NAME}.vcf" ]; then
    if [ -z "$SINGLE_END" ]; then
        echo "Executing command: scif run snippy --outdir $BUILD_FOLDER --ref $REFERENCE_GENOME --R1 $READ1 --R2 $READ2 --unmapped --report --force"
        scif run snippy --outdir $BUILD_FOLDER --ref $REFERENCE_GENOME --R1 $READ1 --R2 $READ2 --unmapped --report --force || { echo "Error: Snippy failed"; exit 1; }
    else
        echo "Executing command: scif run snippy --outdir $BUILD_FOLDER --ref $REFERENCE_GENOME --se $READ1 --unmapped --report --force"
        scif run snippy --outdir $BUILD_FOLDER --ref $REFERENCE_GENOME --se $READ1 --unmapped --report --force || { echo "Error: Snippy failed"; exit 1; }
    fi

    mv ${BUILD_FOLDER}/snps.vcf  ${SAMPLE_FOLDER}/${PIPELINE_NAME}.vcf

    #clean build folder
    if [ -z "$DEBUG" ]; then
        rm -rf $BUILD_FOLDER
    fi
else
    echo "Skipping ${SAMPLE_FOLDER}/${PIPELINE_NAME}.vcf.  Already exists."
fi
