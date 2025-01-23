#!/bin/env sh

#Get Minos Truth
OUTPUT_FOLDER=$1/_minos_download
TMP_OUTPUT_FOLDER=$1/__minos_download
MINOS_TRUTH_GENOME_URL="https://figshare.com/ndownloader/files/30753355"

cd $1/

if [ ! -d $OUTPUT_FOLDER ]; then
    mkdir -p $TMP_OUTPUT_FOLDER
    cd $TMP_OUTPUT_FOLDER
    wget -c $MINOS_TRUTH_GENOME_URL -O - | tar -xz
    cd ..
    mv $TMP_OUTPUT_FOLDER $OUTPUT_FOLDER
else
    echo "Minos download already exists, skipping"
fi

cd $OUTPUT_FOLDER
#get GCA_* IDs
if [ ! -f GCA_000027045.1.fasta ]; then
    wget -O GCA_000027045.1.fasta.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/027/045/GCA_000027045.1_ASM2704v1/GCA_000027045.1_ASM2704v1_genomic.fna.gz"
    gunzip GCA_000027045.1.fasta.gz
fi

if [ ! -f GCF_000784945.1.fasta ]; then
    wget -O GCF_000784945.1.fasta.gz "ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/784/945/GCF_000784945.1_ASM78494v1/GCF_000784945.1_ASM78494v1_genomic.fna.gz"
    gunzip GCF_000784945.1.fasta.gz
fi

cd $1