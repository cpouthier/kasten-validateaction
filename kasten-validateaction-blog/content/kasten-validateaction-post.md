# kasten-validateaction: A Comprehensive Guide

## Overview

The `kasten-validateaction` script is a powerful tool designed to automate the validation of backup data and metadata associated with Restore Points in a Kubernetes cluster. Introduced in Kasten 8.0.5, this script streamlines the process of ensuring data integrity for backups exported using Filesystem mode. By leveraging the capabilities of Kasten K10, users can easily verify the integrity of their backup data with just a few commands.

![Overview Illustration](../assets/illustrations/overview.png)

## Features

The `kasten-validateaction` script comes packed with features that enhance its usability and effectiveness:

- ✅ **Namespace Listing**: Automatically lists all available namespaces in the Kubernetes cluster.
- ✅ **Latest RestorePoint Detection**: Identifies the most recent RestorePoint without manual input.
- ✅ **Customizable Verification**: Prompts users to specify the percentage of data to verify, allowing for tailored validation.
- ✅ **Real-Time Monitoring**: Creates and monitors a ValidateAction, providing real-time updates on the validation process.
- ✅ **Detailed Results Display**: After validation, the script presents comprehensive results, including phase, per-volume statistics, and any errors encountered.
- ✅ **Automatic Cleanup**: Deletes the ValidateAction upon successful validation, keeping the environment tidy.

![Features Illustration](../assets/illustrations/features.png)

## Usage Instructions

To use the `kasten-validateaction` script, follow these simple steps:

1. **Make the Script Executable**:
   Run the following command to give execution permissions to the script:
   ```bash
   chmod +x validateaction.sh
   ```

2. **Execute the Script**:
   Start the validation process by running:
   ```bash
   ./validateaction.sh
   ```

3. **Follow the Prompts**:
   - Select the desired namespace from the list provided.
   - Enter the percentage of files you wish to verify (between 1 and 100).

4. **Monitor the Validation**:
   The script will display the progress of the validation job in real-time.

5. **Review the Results**:
   Once the validation is complete, detailed results will be displayed, including any errors found.

![Usage Illustration](../assets/illustrations/usage.png)

## Troubleshooting Tips

While using the `kasten-validateaction` script, you may encounter some common issues. Here are troubleshooting tips to help you resolve them:

| Issue | Cause | Fix |
|-------|--------|-----|
| `jq: command not found` | The `jq` tool is not installed. | Install it using `apt install jq` or `brew install jq`. |
| `No RestorePoint found` | There are no backups available for the selected namespace. | Ensure that a backup has been created first. |
| ValidateAction remains in Running state | The dataset is large or the cluster is slow. | Wait longer or increase the polling interval in the script. |
| CRDs not found | Kasten K10 is not installed or not ready. | Verify the installation with `kubectl get crds | grep kasten`. |

![Troubleshooting Illustration](../assets/illustrations/troubleshooting.png)

## Conclusion

The `kasten-validateaction` script is an essential tool for Kubernetes users who rely on Kasten K10 for backup and restore operations. By automating the validation process, it not only saves time but also ensures the integrity of critical data. With its user-friendly interface and robust features, this script is a must-have for any Kubernetes administrator.

For more information, check the official Kasten documentation or explore the script's source code in this repository.

---

*This blog post is intended to provide a comprehensive overview of the `kasten-validateaction` script and its functionalities. For further inquiries or contributions, feel free to reach out.*