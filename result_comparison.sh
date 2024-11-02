#!/bin/bash

# Initialize variables
best_model=""
best_f1=0
data_version="1.0"

# Read each line of the CSV file, skipping the header
{ read; while IFS=, read -r data_version model_name precision recall f1_score roc_auc; do
    # Ensure f1_score is numeric
    if [[ "$f1_score" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        # Compare F1-scores to find the best model
        if (( $(echo "$f1_score > $best_f1" | bc -l) )); then
            best_model="$model_name"
            best_f1="$f1_score"
            # You might want to store other metrics here too
        fi
    else
        echo "Invalid F1 score: $model_name for model: $data_version"
    fi
done; } < reports/baseline_model_results.csv

# Generate a Markdown report
echo "# Baseline Model Report" > baseline_model_report.md
echo "Data Version: $data_version" >> baseline_model_report.md
echo "Model Name: $best_model" >> baseline_model_report.md
echo "F1-Score: $best_f1" >> baseline_model_report.md
echo "Confusion Matrix: ![Confusion Matrix](path/to/confusion_matrix.png)" >> baseline_model_report.md

# Sort the results by F1 Score and save to a new file
sort -t, -k5 -n reports/baseline_model_results.csv > sorted_results.csv
