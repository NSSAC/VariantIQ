#!/bin/bash
set -e

OUTPUT=/output
REFERENCE_ACCESSION=NC_000962.3
REF_GENOME_URL="https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=${REFERENCE_ACCESSION}&db=nuccore&report=fasta&extrafeat=null&conwithfeat=on&hide-cdd=on"
REF_GENOME_FILE=${OUTPUT}/${REFERENCE_ACCESSION}.fasta
wget -O $REF_GENOME_FILE $REF_GENOME_URL

echo "Simutator"
mkdir -p $OUTPUT/simutator
cd $OUTPUT_simutator
PREFIX="sim"

scif run simutator mutate_fasta --snps 200 --dels 1000:1,1000:2,1000:3,1000:4,1000:5,1000:10,1000:20,1000:50,10000:100,20000:500,20000:1000,20000:2000,20000:5000,20000:10000 --ins 1000:1,1000:2,1000:3,1000:4,1000:5,1000:10,1000:20,1000:50,10000:100,20000:500,20000:1000,20000:2000,20000:5000,20000:10000 --complex 1000:10:3:0:0:0,1000:10:3:1:1:2,1000:50:10:1:1:3,1000:50:20:3:3:4 $REF_GENOME_FILE $OUTPUT/simutator/$PREFIX
