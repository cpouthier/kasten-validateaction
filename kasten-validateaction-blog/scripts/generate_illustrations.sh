#!/bin/bash

# This script generates illustrations for the kasten-validateaction blog post.
# It uses Graphviz to create visual representations of the script's workflow and features.

# Check if Graphviz is installed
if ! command -v dot &> /dev/null
then
    echo "Graphviz is not installed. Please install it to generate illustrations."
    exit 1
fi

# Create illustrations directory if it doesn't exist
mkdir -p ../assets/illustrations

# Generate workflow diagram
cat <<EOF | dot -Tpng -o ../assets/illustrations/workflow_diagram.png
digraph G {
    rankdir=TB;
    node [shape=box];

    ChooseNamespace [label="Choose Namespace"];
    GetLatestRestorePoint [label="Get Latest RestorePoint"];
    CreateValidateAction [label="Create ValidateAction (YAML)"];
    MonitorUntilComplete [label="Monitor Until Complete/Fail"];
    DisplayValidationResults [label="Display Validation Results"];
    DeleteValidateAction [label="Delete ValidateAction (if OK)"];

    ChooseNamespace -> GetLatestRestorePoint;
    GetLatestRestorePoint -> CreateValidateAction;
    CreateValidateAction -> MonitorUntilComplete;
    MonitorUntilComplete -> DisplayValidationResults;
    DisplayValidationResults -> DeleteValidateAction;
}
EOF

echo "Illustrations generated successfully!"