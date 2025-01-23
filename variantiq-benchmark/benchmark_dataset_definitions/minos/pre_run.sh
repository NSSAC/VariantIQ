#!/bin/env sh

#Get Minos Truth
OUTPUT_FOLDER=$1/_minos_download
MINOS_TRUTH_GENOME_URL="https://figshare.com/ndownloader/files/30753355"
mkdir -p $OUTPUT_FOLDER
cd $OUTPUT_FOLDER
wget -c $MINOS_TRUTH_GENOME_URL -O - | tar -xz

#get GCA_* IDs
wget -O GCA_000027045.1.fasta.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/027/045/GCA_000027045.1_ASM2704v1/GCA_000027045.1_ASM2704v1_genomic.fna.gz"
gunzip GCA_000027045.1.fasta.gz
wget -O GCF_000784945.1.fasta.gz "ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/784/945/GCF_000784945.1_ASM78494v1/GCF_000784945.1_ASM78494v1_genomic.fna.gz"
gunzip GCF_000784945.1.fasta.gz
