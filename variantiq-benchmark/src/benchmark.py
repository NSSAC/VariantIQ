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
GENERATE_REPORT=["scif","run","generate_benchmark_report"]
benchmark=App()

@benchmark.default
def default_action(
    data_directory: str = "/output",
    sample_file: str = "/output/benchmark_samples.csv",
    final_output_directory: str = "/output/benchmark",
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
                
                build_dir = f"{base_build_dir}/{row['sample_name']}/_{vcfname}_bench"
                final_build_output_dir = f"{base_build_dir}/{row['sample_name']}/{vcfname}_bench"
                if not os.path.exists(final_build_output_dir):
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

                    os.rename(build_dir,final_build_output_dir)

        # cp to final location
        run_reporter(base_build_dir)
        os.rename(base_build_dir,final_output_directory)
        print(f"Final output in {final_output_directory}")


def run_normalize(sample_folder,vcf, build_folder):
    print(f"Normalize {sample_folder}")
    cmd = BCFTOOLS + ["norm","-f",f"{sample_folder}/reference_genome.fasta",vcf,"-o",f"{build_folder}/normalized.vcf"]                     
    result = subprocess.run(cmd,capture_output=True, text=True)
    print(f"normalize Output: {result.stdout} {result.stderr}")


def run_varifier(sample_folder,vcf,build_folder):
    print(f"Run Varifier: {sample_folder}")
    cmd = VARIFIER + ["vcf_eval",f"{sample_folder}/truth_genome.fasta",f"{sample_folder}/reference_genome.fasta",vcf,f"{build_folder}/varifier","--force"]
    result = subprocess.run(cmd,capture_output=True, text=True)
    print(f"Varifier Output: {result.stdout} {result.stderr}")

def run_reporter(build_folder):
    print(f"Run reporter: {build_folder}")
    cmd = GENERATE_REPORT + [build_folder,build_folder]
    result = subprocess.run(cmd,capture_output=True, text=True)
    print(f"Reporter Output: {result.stdout} {result.stderr}")

benchmark()