#!/bin/env sh

OUTPUT_FOLDER=$1/_minos_download
MINOS_TRUTH_GENOME_URL="https://figshare.com/ndownloader/files/30753355"
mkdir -p $OUTPUT_FOLDER
cd $OUTPUT_FOLDER
wget -c $MINOS_TRUTH_GENOME_URL -O - | tar -xz
