#!/bin/bash

# Initialize variables
best_model=""
best_f1=0
best_precision=0
best_recall=0
best_roc_auc=0
best_data_version=""

# Read each line of the CSV file, skipping the header
{ read; while IFS=, read -r data_version model_name precision recall f1_score roc_auc; do
    # Ensure f1_score is numeric
    if [[ "$f1_score" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        # Compare F1-scores to find the best model
        if (( $(echo "$f1_score > $best_f1" | bc -l) )); then
            best_model="$model_name"
            best_f1="$f1_score"
            best_precision="$precision"
            best_recall="$recall"
            best_roc_auc="$roc_auc"
            best_data_version="$data_version"  # Store the best data version as well
        fi
    else
        echo "Invalid F1 score for model: $model_name with data version: $data_version"
    fi
done; } < reports/baseline_model_results.csv

# Generate a Markdown report
echo "# Baseline Model Report" > baseline_model_report.md
echo "Data Version: $best_data_version" >> baseline_model_report.md
echo "Model Name: $best_model" >> baseline_model_report.md
echo "F1-Score: $best_f1" >> baseline_model_report.md
echo "Precision: $best_precision" >> baseline_model_report.md
echo "Recall: $best_recall" >> baseline_model_report.md
echo "ROC-AUC: $best_roc_auc" >> baseline_model_report.md

# Set the path for the confusion matrix image for the best model using data_version and model name
output_dir="report-results"
cmp_name="data${best_data_version}_${best_model}_confusion_matrix.png"
confusion_matrix_path="$output_dir/$cmp_name"
echo "Confusion Matrix: ![Confusion Matrix]($confusion_matrix_path)" >> baseline_model_report.md

# Ensure output directory exists and copy the confusion matrix image
if [[ ! -d "$output_dir" ]]; then
    mkdir -p "$output_dir"
fi

# Assume confusion matrix images are stored in "reports" directory
cp "reports/$cmp_name" "$output_dir" 2>/dev/null || echo "Confusion matrix image for $best_model not found."

# Output the key metrics to the terminal for quick reference
echo "Best Model: $best_model"
echo "Data Version: $best_data_version"
echo "Precision: $best_precision"
echo "Recall: $best_recall"
echo "ROC-AUC: $best_roc_auc"
echo "F1-Score: $best_f1"
echo "Confusion Matrix Path: $confusion_matrix_path"

