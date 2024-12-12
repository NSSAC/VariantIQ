#!/usr/bin/env bash

set -e

PIPELINE_NAME="variantiq-bwa-freebayes"
SAMPLE_FOLDER=$1
REFERENCE_GENOME=${SAMPLE_FOLDER}/reference_genome.fasta
READ1=${SAMPLE_FOLDER}/read_1.fastq
READ2=${SAMPLE_FOLDER}/read_2.fastq
TRUTH_GENOME=READ1=${SAMPLE_FOLDER}/truth_genome.fasta
BUILD_FOLDER=${SAMPLE_FOLDER}/_${PIPELINE_NAME}

if [ ! -f "${SAMPLE_FOLDER}/${PIPELINE_NAME}.vcf" ]; then
    echo "Running ${PIPELINE_NAME} pipeline..."
    mkdir -p $BUILD_FOLDER

    #align
    scif run bwa index ${REFERENCE_GENOME}
    scif run bwa mem ${REFERENCE_GENOME} ${READ1} ${READ2} -o ${BUILD_FOLDER}/bwa-mem_aligned_reads.sam
    scif run snippy-samtools view -S -b ${BUILD_FOLDER}/bwa-mem_aligned_reads.sam -o ${BUILD_FOLDER}/bwa-mem_aligned_reads.bam
    scif run snippy-samtools sort ${BUILD_FOLDER}/bwa-mem_aligned_reads.bam -o ${BUILD_FOLDER}/bwa-mem_aligned_reads.sorted.bam
    scif run picard MarkDuplicates I=${BUILD_FOLDER}/bwa-mem_aligned_reads.sorted.bam O=${BUILD_FOLDER}/dedup_bwa-mem_aligned_reads.sorted.bam M=${BUILD_FOLDER}/metrics.txt
    scif run snippy-samtools index ${BUILD_FOLDER}/dedup_bwa-mem_aligned_reads.sorted.bam

    # bcf variants
    echo "BCF Variant calling"
    scif run bcftools mpileup -f ${REFERENCE_GENOME} ${BUILD_FOLDER}/dedup_bwa-mem_aligned_reads.sorted.bam -o ${BUILD_FOLDER}/dedup.mpileup.vcf 
    scif run bcftools call --ploidy 1 -mv -Ov -o ${BUILD_FOLDER}/variants_bcftools.vcf ${BUILD_FOLDER}/dedup.mpileup.vcf
 
    #copy final vcf back to sample folder
    cp ${BUILD_FOLDER}/variants_bcftools.vcf  ${SAMPLE_FOLDER}/${PIPELINE_NAME}.vcf

    #cleanup build folder
    rm -rf ${BUILD_FOLDER}

    #cleanup indexes on the reference genome, but not the genome itself
    rm $SAMPLE_FOLDER/reference_genome.fasta.*
else
    echo "Skipping ${SAMPLE_FOLDER}/${PIPELINE_NAME}.vcf.  Already exists."
fi

