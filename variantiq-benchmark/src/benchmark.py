#!/usr/bin/env python 

#!/usr/bin/env python 
from cyclopts import App
from typing import Literal,Union
import os
import os.path
import json
import subprocess
import csv
import requests
import shutil

VARIFIER=["scif","run","varifier"]

benchmark=App()

@benchmark.default
def default_action(
    data_directory: str = "/output",
    sample_file: str = "/output/benchmark_samples.csv",
    ignore_vcfs: list = []
):
    print("Run BenchMarker")
    print(f"Data Directory: {data_directory} Sample File: {sample_file}")
    with open(sample_file, 'r') as f:       
        print(f"Reading Sample CSV: {sample_file}")
        csv_reader = csv.DictReader(f, delimiter=',')
        for row in csv_reader:
            run_varifier(f"{data_directory}/{row["sample_name"]}")
            # if running vcf tools
            #     run varifier make_truth_vcf truth_genome.vcf
            #     run vcftools
            #
            # copy results to keep to sample_folder
            # remove intermediate files

        # run report generator 
        
def run_varifier(sample_folder):
    cmd = VARIFIER + ["vcf_eval",f"{sample_folder}/truth_genome.fasta",f"{sample_folder}/reference_genome.fasta",f"{sample_folder}/*.vcf",f"${sample_folder}/_varifier"]
    result = subprocess.run(cmd,capture_output=True, text=True)


benchmark()