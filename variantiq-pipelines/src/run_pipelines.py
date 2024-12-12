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
import glob

__dirname__=os.path.dirname(os.path.abspath(__file__))
print(f"Script Directory: {__dirname__}")
VARIFIER=["scif","run","varifier"]

benchmark=App()

@benchmark.command
def list():
    """
    List available benchmark pipelines
    """
    print("Available Pipelines:")
    for pipeline in get_pipelines():
        print(f"- {pipeline}")

@benchmark.command
def run_benchmark_pipelines(
    data_directory: str = "/output",
    sample_file: str = "/output/benchmark_samples.csv",
    ignore_vcfs: list = []
):
    """
    Run benchmark pipelines over a benchmarking dataset
    """
    print("Run Pipelines")
    print(f"Data Directory: {data_directory} Sample File: {sample_file}")
    with open(sample_file, 'r') as f:       
        print(f"Reading Sample CSV: {sample_file}")
        csv_reader = csv.DictReader(f, delimiter=',')
        for row in csv_reader:
            run_pipelines(f"{data_directory}/{row['sample_name']}")


def get_pipelines():
    pipelines=[]
    for file in glob.glob(f"{__dirname__}/pipelines/*.pipeline.sh"):
        pipelines.append(os.path.basename(file).split(".",1)[0])

    return pipelines

def run_pipelines(sample_folder):
    print(f"Run Pipelines: {sample_folder}")
    
    for pipeline in get_pipelines():
        cmd = [f"pipelines/{pipeline}.pipeline.sh",sample_folder]
        print(f"Pipeline Command: {cmd}")
        result = subprocess.run(cmd,cwd=__dirname__,capture_output=True, text=True)
        print(f"Results for {pipeline} {sample_folder}:\n{result.stdout}\n{result.stderr}")

benchmark()