#!/usr/bin/env bash
set -e

echo "Align BWA"
SAMPLE_FOLDER=$1
INSTANCE_NAME=$2
NTHREAD=$3
REFERENCE_GENOME=${SAMPLE_FOLDER}/reference_genome.fasta
READ1=${SAMPLE_FOLDER}/read_1.fastq
READ2=${SAMPLE_FOLDER}/read_2.fastq
TRUTH_GENOME=${SAMPLE_FOLDER}/truth_genome.fasta
BUILD_FOLDER=${SAMPLE_FOLDER}/${INSTANCE_NAME}
mkdir -p $BUILD_FOLDER
if [ ! -f "${BUILD_FOLDER}/aligned_reads.bam" ]; then
    echo "Running ${INSTANCE_NAME} BWA"
    mkdir -p $BUILD_FOLDER

    #link genomes into the build directory and then call from there
    #this allows fasta indexes/artifacts to be generated and cleaned up in the build directory 
    #instead of the sample_folder.
    if [ ! -f "${BUILD_FOLDER}/reference_genome.fasta" ]; then
        ln -s $REFERENCE_GENOME ${BUILD_FOLDER}/reference_genome.fasta
    fi 

    if [ ! -f "${BUILD_FOLDER}/truth_genome.fasta" ]; then
        ln -s $TRUTH_GENOME ${BUILD_FOLDER}/truth_genome.fasta
    fi 
    REFERENCE_GENOME=${BUILD_FOLDER}/reference_genome.fasta
    TRUTH_GENOME=${BUILD_FOLDER}/truth_genome.fasta   

    #align
    scif run bwa index ${REFERENCE_GENOME}

    if [ ! -f "$READ1" ] && [ ! -f "$READ2" ]; then
        echo "Error: No valid input reads found! READ1 ($READ1) and READ2 ($READ2) do not exist." >&2
        exit 1
    fi

    if [ -f "$READ1" ] && [ -f "$READ2" ]; then
        echo "Executing command: scif run bwa mem -t ${NTHREAD} ${REFERENCE_GENOME} ${READ1} ${READ2} -o ${BUILD_FOLDER}/bwa-mem_aligned_reads.sam"
        scif run bwa mem -t ${NTHREAD} ${REFERENCE_GENOME} ${READ1} ${READ2} -o ${BUILD_FOLDER}/bwa-mem_aligned_reads.sam || { echo "Error: BWA mem failed"; exit 1; }
    else
        echo "Executing command: scif run bwa mem -t ${NTHREAD} ${REFERENCE_GENOME} ${READ1} -o ${BUILD_FOLDER}/bwa-mem_aligned_reads.sam"
        scif run bwa mem -t ${NTHREAD} ${REFERENCE_GENOME} ${READ1} -o ${BUILD_FOLDER}/bwa-mem_aligned_reads.sam || { echo "Error: BWA mem failed"; exit 1; }
    fi

    scif run snippy-samtools view -S -b ${BUILD_FOLDER}/bwa-mem_aligned_reads.sam -o ${BUILD_FOLDER}/bwa-mem_aligned_reads.bam
    scif run snippy-samtools sort ${BUILD_FOLDER}/bwa-mem_aligned_reads.bam -o ${BUILD_FOLDER}/bwa-mem_aligned_reads.sorted.bam
    scif run picard MarkDuplicates I=${BUILD_FOLDER}/bwa-mem_aligned_reads.sorted.bam O=${BUILD_FOLDER}/dedup_bwa-mem_aligned_reads.sorted.bam M=${BUILD_FOLDER}/metrics.txt
    scif run snippy-samtools index ${BUILD_FOLDER}/dedup_bwa-mem_aligned_reads.sorted.bam
    mv ${BUILD_FOLDER}/dedup_bwa-mem_aligned_reads.sorted.bam ${BUILD_FOLDER}/aligned_reads.bam
    [ -f "${BUILD_FOLDER}/dedup_bwa-mem_aligned_reads.sorted.bam.bai" ] && mv ${BUILD_FOLDER}/dedup_bwa-mem_aligned_reads.sorted.bam.bai ${BUILD_FOLDER}/aligned_reads.bam.bai
else
    echo "Skipping ${INSTANCE_NAME} Aligner"
fi
