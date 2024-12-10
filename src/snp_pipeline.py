#!/usr/bin/env python

import click

@click.command()
@click.option("--sra-reads","-s", default=None,help="SRA ID for reach")
@click.option("--illumina-read-files","-r", default=None,nargs=2, help="Comma separated pair of read files")

@click.option("--reference-genome-url","-u", default=None, help="URL to retrieve Reference Genome FASTA")
@click.option("--reference-genome-accession","-a", default=None,help="NCBI Accession to retreive as Reference Genome")
@click.option("--reference-genome-file","-f", default=None,help="Reference Genome FASTA file")

@click.option("--input", default=None,help="User Input Data")
# can provide multiple vcf files
@click.option("--output","-o", default=".", help="Output Location")
@click.option("--cores","-c", default=1,help="Number of cores to use")
@click.argument("label")





def run(
        label,
        sra_reads,
        read_files,
        reference_genome_url,
        reference_genome_accession,
        reference_genome_file,
        output,
        cores
    ):
    if label is None:
        print("Missing Label")
        exit(1)
       
    if sra_reads is None and read_files is None:
        print("Missing read file options (--sra-read or --read-files)")
        exit(1)

    if reference_genome_url is None and reference_genome_accession is None and reference_genome_file is None:
        print("Missing Reference Genome option (--reference-genome-url,--reference-genome-accession, or --reference-genome-file)")
        exit(1)

    if sra_reads is not None:
        read_files = getReadsFromSRA(sra_reads)
    
    if read_files is None:
        print("No Read Files found with provided parameters")
        exit(1)

    print(f"Read Files: {read_files}")

    if reference_genome_url is not None:
        reference_genome_file = getReferenceGenome(reference_genome_url)
    elif reference_genome_accession is not None:
        reference_genome_file = getReferenceGenome(f"https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id={reference_genome_accession}&db=nuccore&report=fasta&extrafeat=null&conwithfeat=on&hide-cdd=on")

    print(f"Reference Genome File: {reference_genome_file}")


def getReferenceGenome(url):
    return "reference_genome.fasta"
              
def getReadsFromSRA(sra_reads):
    print("Reads from SRA ID: ", sra_reads)
    return ("readfile_1.fastq","readfile_2.fastq")

if __name__ == '__main__':
    run()
