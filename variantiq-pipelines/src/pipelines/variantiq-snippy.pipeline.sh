#!/usr/bin/env bash
set -e

echo "VariantIQ Snippy Pipeline"
PIPELINE_NAME="variantiq-snippy"
SAMPLE_FOLDER=$1
SNIPPY_OUT=${SAMPLE_FOLDER}/_${PIPELINE_NAME}
mkdir -p $SNIPPY_OUT
scif run snippy --outdir $SNIPPY_OUT --ref $SAMPLE_FOLDER/reference_genome.fasta --R1 $SAMPLE_FOLDER/read_1.fastq --R2 $SAMPLE_FOLDER/read_2.fastq --unmapped --report --force
cp $SNIPPY_OUT/snps.vcf ${SAMPLE_FOLDER}/${PIPELINE_NAME}.vcf
rm -rf $SNIPPY_OUT
