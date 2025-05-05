#!/usr/bin/env bash
set -e

PIPELINE_NAME="variantiq-bwa-freebayes"
SAMPLE_FOLDER=$1
DEBUG=$2
REFERENCE_GENOME=${SAMPLE_FOLDER}/reference_genome.fasta
READ1=${SAMPLE_FOLDER}/read_1.fastq
READ2=${SAMPLE_FOLDER}/read_2.fastq
TRUTH_GENOME=${SAMPLE_FOLDER}/truth_genome.fasta
BUILD_FOLDER=${SAMPLE_FOLDER}/_${PIPELINE_NAME}
PATH=$PATH:./pipelines:./pipelines/aligners

if [ ! -f "${SAMPLE_FOLDER}/${PIPELINE_NAME}.vcf" ]; then
    echo "Running ${PIPELINE_NAME} pipeline..."
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

    ALIGNER_INSTANCE=_shared/bwa_alignment
    align-bwa.sh $SAMPLE_FOLDER $ALIGNER_INSTANCE
    ALIGNER_FOLDER=${SAMPLE_FOLDER}/$ALIGNER_INSTANCE

    if [ ! -f "${ALIGNER_FOLDER}/aligned_reads.bam" ]; then
        echo "Alignment file missing: ${ALIGNER_FOLDER}/aligned_reads.bam.  This probably means the alignment step failed"
        exit 1
    fi

    # freebayes variants
    echo "Freebayes Variant calling"
	scif run freebayes -f ${REFERENCE_GENOME} --ploidy 1 ${ALIGNER_FOLDER}/aligned_reads.bam -v ${BUILD_FOLDER}/variants_freebayes.vcf
 
    #copy final vcf back to sample folder
    mv ${BUILD_FOLDER}/variants_freebayes.vcf  ${SAMPLE_FOLDER}/${PIPELINE_NAME}.vcf

    #cleanup build folder
    if [ -z "$DEBUG"]; then
        rm -rf $BUILD_FOLDER
    fi
else
    echo "Skipping ${SAMPLE_FOLDER}/${PIPELINE_NAME}.vcf.  Already exists."
fi

