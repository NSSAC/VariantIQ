#!/bin/env sh

OUTPUT_FOLDER=$1
ID=$2
TARGET_FOLDER=$3
MINOS_SRC_FOLDER=$OUTPUT_FOLDER/_minos_download
TG=`find $MINOS_SRC_FOLDER/ -name $ID`
RP=`realpath $TG --relative-to=$TARGET_FOLDER`
ln -s $RP $TARGET_FOLDER/truth_genome.fasta
