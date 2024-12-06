#!/bin/bash
set -e

#INPUTS
OUTPUT=/output
INPUT=/input
SRAID=ERR2704678
# REF_GENOME_URL="https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=NC_000962.3&db=nuccore&report=fasta&extrafeat=null&conwithfeat=on&hide-cdd=on"
REFERENCE_ACCESSION=NC_000962.3
MINOS_TRUTH_GENOME_URL="https://figshare.com/ndownloader/files/30753355"
CPUS=2

# get reads
#scif run fastq-dump --split-files -O $OUTPUT $SRAID 
#gunzip $OUTPUT/*.gz

#get reference genome
REF_GENOME_URL="https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=${REFERENCE_ACCESSION}&db=nuccore&report=fasta&extrafeat=null&conwithfeat=on&hide-cdd=on"
REF_GENOME_FILE=${OUTPUT}/${REFERENCE_ACCESSION}.fasta
#wget -O $REF_GENOME_FILE $REF_GENOME_URL

# get minos truth genome
mkdir -p $OUTPUT/minos_truth_genome
cd $OUTPUT/minos_truth_genome
#wget -c $MINOS_TRUTH_GENOME_URL -O - | tar -xz
# ... need to be able to translate the input to a targetable file name for later...
MT_FOLDER=`ls -1 ${OUTPUT}/minos_truth_genome/`
MINOS_TRUTH=$OUTPUT/minos_truth_genome/${MT_FOLDER}
echo "Minos Truthe Genome: $MINOS_TRUTH"

# run snippy
SNIPPY_OUT=${OUTPUT}/snippy
mkdir -p $SNIPPY_OUT
#scif run snippy --cpus $CPUS --outdir $SNIPPY_OUT --ref $REF_GENOME_FILE --R1 ${OUTPUT}/${SRAID}_1.fastq --R2 ${OUTPUT}/${SRAID}_2.fastq --unmapped --report --force

# test SNP pipeline
#scif run bwa index $REF_GENOME_FILE
#scif run bwa mem $REF_GENOME_FILE  ${OUTPUT}/${SRAID}_1.fastq  ${OUTPUT}/${SRAID}_2.fastq -o ${OUTPUT}/${SRAID}_bwa-mem_aligned_reads.sam
#scif run snippy-samtools view -S -b ${OUTPUT}/${SRAID}_bwa-mem_aligned_reads.sam -o ${OUTPUT}/${SRAID}_bwa-mem_aligned_reads.bam
#scif run snippy-samtools sort ${OUTPUT}/${SRAID}_bwa-mem_aligned_reads.bam -o ${OUTPUT}/${SRAID}_bwa-mem_aligned_reads.sorted.bam
#scif run picard MarkDuplicates I=${OUTPUT}/${SRAID}_bwa-mem_aligned_reads.sorted.bam O=${OUTPUT}/${SRAID}_dedup_bwa-mem_aligned_reads.sorted.bam M=${OUTPUT}/${SRAID}_metrics.txt
#scif run snippy-samtools index ${OUTPUT}/${SRAID}_dedup_bwa-mem_aligned_reads.sorted.bam

# bcf variants
#scif run bcftools mpileup -f $REF_GENOME_FILE ${OUTPUT}/${SRAID}_dedup_bwa-mem_aligned_reads.sorted.bam -o ${OUTPUT}/${SRAID}_dedup.mpileup.vcf 
#scif run bcftools call --ploidy 1 -mv -Ov -o ${OUTPUT}/${SRAID}_variants_bcftools.vcf ${OUTPUT}/${SRAID}_dedup.mpileup.vcf
#rm ${OUTPUT}/${SRAID}_dedup.mpileup.vcf

# freebayes variants
#scif run freebayes -f $REF_GENOME_FILE --ploidy 1 ${OUTPUT}/${SRAID}_dedup_bwa-mem_aligned_reads.sorted.bam -v ${OUTPUT}/${SRAID}_variants_freebayes.vcf

#normalize with bcftools
#scif run bcftools norm -f $REF_GENOME_FILE ${OUTPUT}/${SRAID}_variants_bcftools.vcf -o ${OUTPUT}/${SRAID}_bcf_normalized_variants_bcftools.vcf
#scif run bcftools norm -f $REF_GENOME_FILE ${OUTPUT}/${SRAID}_variants_freebayes.vcf -o ${OUTPUT}/${SRAID}_bcf_normalized_variants_freebayes.vcf

#normalize with vt
#vt normalize -r $REF_GENOME_FILE ${OUTPUT}/${SRAID}_variants_bcftools.vcf > ${OUTPUT}/${SRAID}_vt_normalized_variants_bcftools.vcf
#vt normalize -r $REF_GENOME_FILE ${OUTPUT}/${SRAID}_variants_freebayes.vcf > ${OUTPUT}/${SRAID}_vt_normalized_variants_freebayes.vcf

# minos adjudicate
mkdir -p $OUTPUT/minos
scif run minos adjudicate --reads ${OUTPUT}/${SRAID}_1.fastq --reads ${OUTPUT}/${SRAID}_2.fastq ${OUTPUT}/minos $REF_GENOME_FILE ${OUTPUT}/${SRAID}_bcf_normalized_variants_bcftools.vcf ${OUTPUT}/${SRAID}_bcf_normalized_variants_freebayes.vcf --force

# mkdir -p $OUTPUT/varifier
# scif run varifier vcf_eval $MINOS_TRUTH/Assemblies/mtb.N0054.fasta Mycobacterium_tuberculosis_H37Rv.fasta normalized_ERR2704678_variants_bcftools.vcf.gz test_varifier --force
# simutator mutate_fasta --snps 100 Mycobacterium_tuberculosis_H37Rv.fasta test_simutator

