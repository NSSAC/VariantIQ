#!/bin/env bash

OUTPUT_FOLDER=$1
ID=$2
TARGET_FOLDER=$3
NCBI_REF_GENOME_URL="https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=__reference_genome__&db=nuccore&report=fasta&extrafeat=null&conwithfeat=on&hide-cdd=on"
MINOS_SRC_FOLDER=$OUTPUT_FOLDER/_minos_download

if [[ $ID == GCF_* ]]; then
    TG=$MINOS_SRC_FOLDER/GCF_000784945.1.fasta
    RP=`realpath $TG --relative-to=$TARGET_FOLDER`
    ln -s $RP $TARGET_FOLDER/reference_genome.fasta
elif [[ $ID == GCA_* ]]; then
    TG=$MINOS_SRC_FOLDER/GCA_000027045.1.fasta
    RP=`realpath $TG --relative-to=$TARGET_FOLDER`
    ln -s $RP $TARGET_FOLDER/reference_genome.fasta
else
    URL=${NCBI_REF_GENOME_URL/__reference_genome__/$ID}
    curl -o $TARGET_FOLDER/reference_genome.fasta $URL
fi

