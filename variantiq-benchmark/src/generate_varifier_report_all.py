import os
import json
import sys
import pandas as pd
import matplotlib.pyplot as plt
import argparse
import seaborn as sns
from jinja2 import Environment, FileSystemLoader  # For HTML report generation

# Function to parse summary_stats.json
def parse_summary_stats(file_path):
    with open(file_path, "r") as f:
        data = json.load(f)
    # Flatten all fields and values in the JSON file
    flattened_data = {}
    
    def flatten_dict(d, prefix=""):
        for key, value in d.items():
            if isinstance(value, dict):
                flatten_dict(value, prefix=f"{prefix}{key}_")
            else:
                flattened_data[f"{prefix}{key}"] = value

    flatten_dict(data)

    if "Precision_Precision" in flattened_data and "Recall_Recall" in flattened_data:
        precision = flattened_data["Precision_Precision"]
        recall = flattened_data["Recall_Recall"]
        if precision + recall > 0:  # Avoid division by zero
            f1_score = 2 * (precision * recall) / (precision + recall)
            flattened_data["F1_score"] = round(f1_score, 4)
        else:
            flattened_data["F1_score"] = 0.0000
    return flattened_data

# Main function
def main(base_dir, output_dir):
    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Collect data from all samples and pipelines
    results = []
    for root, dirs, files in os.walk(base_dir):
        if "summary_stats.json" in files:
            file_path = os.path.join(root, "summary_stats.json")
            # Extract sample and pipeline from the directory structure
            parts = root.split(os.sep)
            sample = parts[-3]  # Assuming 'sample1/pipeline1/varifier/'
            pipeline = parts[-2]
            parsed_data = parse_summary_stats(file_path)
            parsed_data.update({"Sample": sample, "Pipeline": pipeline})
            results.append(parsed_data)

    # Create a DataFrame for easy visualization and manipulation
    df = pd.DataFrame(results)

    # Ensure "Sample" and "Pipeline" columns appear first
    columns_order = ["Sample", "Pipeline"] + [col for col in df.columns if col not in ["Sample", "Pipeline"]]
    df = df[columns_order]

    # Sort the DataFrame by Sample and Pipeline
    df = df.sort_values(by=["Sample", "Pipeline"])

    # Save the table as a CSV
    csv_path = os.path.join(output_dir, "benchmark_results.csv")
    df.to_csv(csv_path, index=False)

    # Generate plots (line and violin) and save file paths
    plots = []

    # Precision Line Plot
    if "Precision_Precision" in df.columns:
        # Precision Line Plot
        precision_plot_path = os.path.join(output_dir, "precision_plot.png")
        plt.figure(figsize=(24, 18))
        for sample in df["Sample"].unique():
            sample_data = df[df["Sample"] == sample]
            plt.plot(sample_data["Pipeline"], sample_data["Precision_Precision"], label=f"{sample} Precision", marker="o")
        plt.title("Precision for All Samples", fontsize=20)
        plt.xlabel("Pipeline", fontsize=18)
        plt.ylabel("Precision", fontsize=18)
        plt.tick_params(axis="x", labelsize=14)
        plt.tick_params(axis="y", labelsize=14)
        plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left', fontsize=9)  # Adjust legend font size
        plt.grid(True)  # Add grid lines for better readability
        plt.tight_layout(pad=5)  # Reduce padding slightly
        plt.savefig(precision_plot_path)
        plt.close()
        plots.append("precision_plot.png")
    
        # Precision Strip Plot
        precision_violin_path = os.path.join(output_dir, "precision_violin_strip_plot.png")
        plt.figure(figsize=(24, 18))
        sns.stripplot(
            x="Pipeline", y="Precision_Precision", data=df, hue="Sample",
            dodge=True, palette="bright", jitter=True, alpha=0.8  # Add colored dots
        )
        plt.title("Precision Distribution", fontsize=20)
        plt.xlabel("Pipeline", fontsize=18)
        plt.ylabel("Precision", fontsize=18)
        plt.tick_params(axis="x", labelsize=14)
        plt.tick_params(axis="y", labelsize=14)
        plt.legend(bbox_to_anchor=(1.05, 1), loc="upper left", fontsize=9)
        plt.tight_layout(pad=5)
        plt.savefig(precision_violin_path)
        plt.close()
        plots.append("precision_violin_strip_plot.png")
 
        # Precision Violin Plot
        precision_violin_path = os.path.join(output_dir, "precision_violin_plot.png")
        plt.figure(figsize=(24, 18))
        sns.violinplot(
            x="Pipeline", y="Precision_Precision", data=df
        )
        plt.title("Precision Distribution", fontsize=20)
        plt.xlabel("Pipeline", fontsize=18)
        plt.ylabel("Precision", fontsize=18)
        plt.tick_params(axis="x", labelsize=14)
        plt.tick_params(axis="y", labelsize=14)
        plt.tight_layout(pad=5)
        plt.savefig(precision_violin_path)
        plt.close()
        plots.append("precision_violin_plot.png")

    
    if "Recall_Recall" in df.columns:
        # Recall Line Plot
        recall_plot_path = os.path.join(output_dir, "recall_plot.png")
        plt.figure(figsize=(24, 18))
        for sample in df["Sample"].unique():
            sample_data = df[df["Sample"] == sample]
            plt.plot(sample_data["Pipeline"], sample_data["Recall_Recall"], label=f"{sample} Recall", marker="o")
        plt.title("Recall for All Samples", fontsize=20)
        plt.xlabel("Pipeline", fontsize=18)
        plt.ylabel("Recall", fontsize=18)
        plt.tick_params(axis="x", labelsize=14)
        plt.tick_params(axis="y", labelsize=14)
        plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left', fontsize=9)
        plt.grid(True)
        plt.tight_layout(pad=5)
        plt.savefig(recall_plot_path)
        plt.close()
        plots.append("recall_plot.png")
    
        # Recall Strip Plot
        recall_violin_path = os.path.join(output_dir, "recall_violin_strip_plot.png")
        plt.figure(figsize=(24, 18))
        sns.stripplot(
            x="Pipeline", y="Recall_Recall", data=df, hue="Sample",
            dodge=True, palette="bright", jitter=True, alpha=0.8
        )
        plt.title("Recall Distribution", fontsize=20)
        plt.xlabel("Pipeline", fontsize=18)
        plt.ylabel("Recall", fontsize=18)
        plt.tick_params(axis="x", labelsize=14)
        plt.tick_params(axis="y", labelsize=14)
        plt.legend(bbox_to_anchor=(1.05, 1), loc="upper left", fontsize=9)
        plt.tight_layout(pad=5)
        plt.savefig(recall_violin_path)
        plt.close()
        plots.append("recall_violin_strip_plot.png")

        # Recall Violin Plot
        recall_violin_path = os.path.join(output_dir, "recall_violin_plot.png")
        plt.figure(figsize=(24, 18))
        sns.violinplot(
            x="Pipeline", y="Recall_Recall", data=df
        )
        plt.title("Recall Distribution", fontsize=20)
        plt.xlabel("Pipeline", fontsize=18)
        plt.ylabel("Recall", fontsize=18)
        plt.tick_params(axis="x", labelsize=14)
        plt.tick_params(axis="y", labelsize=14)
        plt.tight_layout(pad=5)
        plt.savefig(recall_violin_path)
        plt.close()
        plots.append("recall_violin_plot.png")

    if "F1_score" in df.columns:
        # F1_score Violin Plot
        F1_score_violin_path = os.path.join(output_dir, "F1_score_violin_plot.png")
        plt.figure(figsize=(24, 18))
        sns.violinplot(
            x="Pipeline", y="F1_score", data=df
        )
        plt.title("F1 Score Distribution", fontsize=20)
        plt.xlabel("Pipeline", fontsize=18)
        plt.ylabel("F1 score", fontsize=18)
        plt.tick_params(axis="x", labelsize=14)
        plt.tick_params(axis="y", labelsize=14)
        plt.tight_layout(pad=5)
        plt.savefig(F1_score_violin_path)
        plt.close()
        plots.append("F1_score_violin_plot.png")
                
    # Generate HTML report using Jinja2
    env = Environment(loader=FileSystemLoader(searchpath="./"))
    template = env.from_string("""
    <html>
    <head>
        <title>Benchmark Report</title>
        <style>
            body {
                  font-family: arial, sans-serif;
            }
            table {
                  font-family: arial, sans-serif;
                  font-size: 8px;
                  border-collapse: collapse;
                  width: 100%;
            }
            td, th {
                  border: 1px solid #dddddd;
                  text-align: left;
                  padding: 1px;
            }
            tr:nth-child(even) {
                  background-color: #dddddd;
            }
        </style>
    </head>
    <body>
        <h1>Benchmark Report</h1>
        <p>This benchmark report summarizes the variant calls generated by various SNP calling pipelines using a benchmark dataset. We utilized <a href="https://github.com/iqbal-lab-org/varifier">Varifier</a>, a benchmarking tool, to compute and evaluate the statistics of variant calling results. The findings are presented in the table below, while the precision and recall metrics, alongside line, strip, and violin plots for each variant caller on the benchmark dataset, are illustrated below. The data points on these plots represent each sample across various SNP pipelines.</p>
        {% if 'F1_score_violin_plot.png' in plots %}
        <h2>F1 Score Violin Plot</h2>
        <img src="F1_score_violin_plot.png" alt="F1 Score Violin Plot" width="1000">
        {% endif %}
        {% if 'precision_violin_plot.png' in plots %}
        <h2>Precision Violin Plot</h2>
        <img src="precision_violin_plot.png" alt="Precision Violin Plot" width="1000">
        {% endif %}
        {% if 'recall_violin_plot.png' in plots %}
        <h2>Recall Violin Plot</h2>
        <img src="recall_violin_plot.png" alt="Recall Violin Plot" width="1000">
        {% endif %}
        {% if 'precision_plot.png' in plots %}
        <h2>Precision Line Plot</h2>
        <img src="precision_plot.png" alt="Precision Line Plot" width="1000">
        {% endif %}
        {% if 'recall_plot.png' in plots %}
        <h2>Recall Line Plot</h2>
        <img src="recall_plot.png" alt="Recall Line Plot" width="1000">
        {% endif %}
        {% if 'precision_violin_strip_plot.png' in plots %}
        <h2>Precision Strip Plot</h2>
        <img src="precision_violin_strip_plot.png" alt="Precision Violin Plot" width="1000">
        {% endif %}
        {% if 'recall_violin_strip_plot.png' in plots %}
        <h2>Recall Strip Plot</h2>
        <img src="recall_violin_strip_plot.png" alt="Recall Violin Plot" width="1000">
        {% endif %}
        <h2>Benchmark Results Table</h2>
        
        <table border="1">
            <tr>
                {% for column in columns %}
                <th>{{ column }}</th>
                {% endfor %}
            </tr>
            {% for row in rows %}
            <tr>
                {% for column in columns %}
                <td>{{ row[column] }}</td>
                {% endfor %}
            </tr>
            {% endfor %}
        </table>
    </body>
    </html>
    """)

    html_content = template.render(columns=df.columns, rows=df.to_dict(orient="records"), plots=plots)

    html_path = os.path.join(output_dir, "benchmark_report.html")
    with open(html_path, "w") as html_file:
        html_file.write(html_content)

    print(f"Reports generated in: {output_dir}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python generate_varifier_report_all.py <path_to_benchmark_base_directory> <path_to_output_directory>")
        sys.exit(1)
    # Add argument parser
    parser = argparse.ArgumentParser(description="Generate benchmark reports.")
    parser.add_argument("base_dir", type=str, help="Path to the base directory containing sample benchmark data.")
    parser.add_argument("output_dir", type=str, help="Path to the output directory for generated reports.")
    args = parser.parse_args()
    main(args.base_dir, args.output_dir)
    