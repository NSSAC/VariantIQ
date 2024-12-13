import json
import sys
import os
from jinja2 import Template
import matplotlib.pyplot as plt

# Check if the JSON file path is provided
if len(sys.argv) != 2:
	print("Usage: python generate_report.py <path_to_summary_stats.json>")
	sys.exit(1)

json_file_path = sys.argv[1]

# Load JSON data with error handling
try:
	with open(json_file_path) as f:
		data = json.load(f)
except FileNotFoundError:
	print(f"Error: File {json_file_path} not found.")
	sys.exit(1)
except json.JSONDecodeError:
	print(f"Error: File {json_file_path} is not a valid JSON.")
	sys.exit(1)

# Ensure data is in the correct format
if not isinstance(data, dict):
	print("Error: JSON data is not a dictionary.")
	sys.exit(1)

# Extract relevant metrics
metrics = ['Precision', 'Recall']
values = [data['Precision']['Precision'], data['Recall']['Recall']]

# Print metrics and values for debugging
print("Metrics:", metrics)
print("Values:", values)

plt.figure(figsize=(10, 5))
plt.bar(metrics, values)
plt.xlabel('Metrics')
plt.ylabel('Values')
plt.title('Precision and Recall Metrics')

# Ensure the output directory exists
output_dir = os.path.dirname(json_file_path)
os.makedirs(output_dir, exist_ok=True)
plot_path = os.path.join(output_dir, 'metrics_plot.png')

# Save the plot with error handling
try:
	plt.savefig(plot_path)
	print(f"Plot saved successfully at {plot_path}")
except Exception as e:
	print(f"Error saving plot: {e}")
	sys.exit(1)

# Flatten the nested dictionaries for the HTML report
def flatten_dict(d, parent_key='', sep='_'):
	items = []
	for k, v in d.items():
		new_key = f"{parent_key}{sep}{k}" if parent_key else k
		if isinstance(v, dict):
			items.extend(flatten_dict(v, new_key, sep=sep).items())
		else:
			items.append((new_key, v))
	return dict(items)

#flattened_data = {k: flatten_dict(v) if isinstance(v, dict) else v for k, v in data.items()}
flattened_data = flatten_dict(data)

# Define a simple HTML template
template = Template('''
<html>
<head><title>Precision and Recall Report</title></head>
<body>
<h1>Precision and Recall Report</h1>
<img src="metrics_plot.png" alt="Metrics Plot">
<table border="1">
<tr>
<th>Metric</th>
<th>Value</th>
</tr>
{% for key, value in flattened_data.items() %}
<tr>
<td>{{ key }}</td>
<td>{{ value }}</td>
</tr>
{% endfor %}
</table>
</body>
</html>
''')

# Render the template with data
html_content = template.render(flattened_data=flattened_data, plot_path=plot_path)

# Save the HTML report
output_html_path = json_file_path.replace('.json', '.html')
with open(output_html_path, 'w') as f:
	f.write(html_content)

print(f"HTML report generated: {output_html_path}")
