#!/usr/bin/env python 

#!/usr/bin/env python 
from cyclopts import App
from typing import Literal,Union
import os
import os.path
import subprocess
import csv
import glob

VARIFIER=["scif","run","varifier"]
#BCFTOOLS=["scif","run","bcftools"]
BCFTOOLS=["micromamba","run","--name","variantiq","bcftools"]
benchmark=App()

@benchmark.default
def default_action(
    data_directory: str = "/output",
    sample_file: str = "/output/benchmark_samples.csv",
    ignore_vcfs: list = []
):
    print("Run BenchMarker")
    print(f"Data Directory: {data_directory} Sample File: {sample_file}")
    base_build_dir = f"{data_directory}/_benchmark"
    try:
        os.mkdir(base_build_dir)
    except FileExistsError:
        pass

    with open(sample_file, 'r') as f:       
        print(f"Reading Sample CSV: {sample_file}")
        csv_reader = csv.DictReader(f, delimiter=',')
        for row in csv_reader:
            sample_folder = f"{data_directory}/{row['sample_name']}"
            vcfs = glob.glob(f"{sample_folder}/*.vcf")
            for vcf in vcfs:
                print(f"VCF: {vcf}")
                vcfname,ext = os.path.splitext(os.path.basename(vcf))
                print(f"VCF Name: {vcfname}")
                build_dir = f"{base_build_dir}/{row['sample_name']}/{vcfname}_bench"
                try:
                    os.makedirs(build_dir)
                except FileExistsError:
                    pass
                
                run_normalize(sample_folder,vcf,build_dir)
                run_varifier(sample_folder,f"{build_dir}/normalized.vcf",build_dir)
                
                # if running vcfdist
                #     run varifier make_truth_vcf truth_genome.fasta
                #     run vcfdist
                #

                # run sample level report generator

                # copy results to keep to sample_folder

                # remove intermediate files

        # run full generator 
        # cp to final location
        # remove base_build_dir
        

def run_normalize(sample_folder,vcf, build_folder):
    print(f"Normalize {sample_folder}")
    # scif run bcftools norm -f $REF_GENOME_FILE ${OUTPUT}/${SRAID}_variants_bcftools.vcf -o ${OUTPUT}/${SRAID}_bcf_normalized_variants_bcftools.vcf

    cmd = BCFTOOLS + ["norm","-f",f"{sample_folder}/reference_genome.fasta",vcf,"-o",f"{build_folder}/normalized.vcf"]                     
    result = subprocess.run(cmd,capture_output=True, text=True)
    print(f"normalize Output: {result.stdout} {result.stderr}")


def run_varifier(sample_folder,vcf,build_folder):
    print(f"Run Varifier: {sample_folder}")
    cmd = VARIFIER + ["vcf_eval",f"{sample_folder}/truth_genome.fasta",f"{sample_folder}/reference_genome.fasta",vcf,f"{build_folder}/varifier","--force"]
    result = subprocess.run(cmd,capture_output=True, text=True)
    print(f"Varifier Output: {result.stdout} {result.stderr}")

benchmark()