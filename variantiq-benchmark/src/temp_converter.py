import csv

def tsv_to_csv(input_tsv, output_csv):
    with open(input_tsv, 'r') as tsv_file, open(output_csv, 'w', newline='') as csv_file:
        # Read the TSV file
        tsv_reader = csv.DictReader(tsv_file, delimiter='\t')
        
        # Define the fieldnames for the CSV
        fieldnames = ['sample_name', 'read_files', 'reference_genome', 'truth_genome']
        csv_writer = csv.DictWriter(csv_file, fieldnames=fieldnames)

        # Write the header to the CSV file
        csv_writer.writeheader()

        # Process each row in the TSV file
        for row in tsv_reader:
            # Get relevant fields
            print(f"ROW: {row}")
            sample_name = row['Sample name']
            read_files = row['ENA_Illumina_run']
            reference_genome = row['Reference accession']
            truth_genome = row['Truth genome file name']

            # Handle multiple `ENA_pacbio_sample` values
            if read_files:
                pacbio_samples = [s.strip() for s in read_files.split(',')]
            else:
                pacbio_samples = [None]

            print(f"pacbio_samples: {pacbio_samples}")
            for pacbio_sample in pacbio_samples:
                combined_sample_name = f"{sample_name}_{pacbio_sample}" if pacbio_sample else sample_name
                csv_writer.writerow({
                    'sample_name': combined_sample_name,
                    'read_files': pacbio_sample,
                    'reference_genome': reference_genome,
                    'truth_genome': truth_genome
                })

# Replace with your actual file paths
input_tsv_path = '/variantiq/test/Minos_benchmark_real_data_tab.txt'
output_csv_path = 'samples.csv'

# Call the function
tsv_to_csv(input_tsv_path, output_csv_path)
