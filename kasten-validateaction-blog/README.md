# kasten-validateaction Blog Post

## Overview

In the world of Kubernetes, ensuring the integrity of backup data is crucial for maintaining application reliability. The `kasten-validateaction` script automates the validation of the latest Kasten RestorePoint in a Kubernetes cluster. This script simplifies the process of verifying backup data and metadata, allowing users to focus on their applications rather than the intricacies of backup management.

## Features

The `kasten-validateaction` script comes packed with features designed to enhance user experience:

- **Namespace Listing**: Automatically lists all available namespaces in the cluster.
- **Latest RestorePoint Detection**: Identifies the most recent RestorePoint without manual input.
- **Customizable Verification**: Prompts users to specify the percentage of data to verify, allowing for tailored validation.
- **Real-Time Monitoring**: Creates and monitors a `ValidateAction`, providing updates until completion.
- **Detailed Results Display**: Outputs comprehensive validation results, including phase, per-volume statistics, and any errors encountered.
- **Automatic Cleanup**: Deletes the `ValidateAction` upon successful validation, keeping the environment tidy.

## Usage Instructions

To use the `kasten-validateaction` script, follow these steps:

1. Ensure you have the necessary components installed:
   - `kubectl`: Configured and authenticated with your Kubernetes cluster.
   - `jq`: For parsing JSON output.
   - `column`: For displaying clean, aligned tables.
   - Kasten K10: Installed in your cluster.

2. Make the script executable and run it:
   ```
   chmod +x validateaction.sh
   ./validateaction.sh
   ```

3. Follow the prompts to select a namespace, specify the RestorePoint, and choose the percentage of files to verify.

### Example Output

Upon successful execution, the script will display output similar to the following:

```
=== Available namespaces ===
default
wordpress
kasten-io
============================

Enter the concerned namespace: wordpress
🔍 Searching for the latest RestorePoint in namespace 'wordpress'...

✅ Latest RestorePoint in 'wordpress': scheduled-czqcd9ngj2

Enter percentage of files to verify (1–100): 100
✅ Creating ValidateAction for restore point 'scheduled-czqcd9ngj2'...

⏳ Monitoring progress (refresh every 1s)...
validate-sample-app-abc12   Running   2025-10-20T15:51:04Z
validate-sample-app-abc12   Complete  2025-10-20T15:51:04Z

===== Action Details =====
ATTEMPT  STATE      START                    END
1        succeeded  2025-10-20T15:51:04Z     2025-10-20T15:51:11Z

APP        VOLUME                     ERRCOUNT  READ_FILES  READ_BYTES
wordpress  wordpress                  0         1219        20326822
wordpress  data-wordpress-mariadb-0   0         18          124083941

No errors reported (errorCount=0).
```

## Troubleshooting Tips

While using the script, you may encounter some common issues. Here are troubleshooting tips to help you resolve them:

| Issue | Cause | Fix |
|-------|--------|-----|
| `jq: command not found` | jq not installed | Install with `apt install jq` or `brew install jq` |
| `No RestorePoint found` | No backups exist for the namespace | Run a backup first |
| ValidateAction stays in Running | Large data set or slow cluster | Wait longer or increase polling interval |
| CRDs not found | Kasten K10 not installed or not ready | Verify `kubectl get crds | grep kasten` |

## Illustrations

To enhance understanding, the blog post will include generated illustrations that visually represent the workflow of the `kasten-validateaction` script. These illustrations will depict the various stages of the validation process, from selecting a namespace to displaying results.

## Conclusion

The `kasten-validateaction` script is a powerful tool for Kubernetes users looking to ensure the integrity of their backup data. By automating the validation process, it saves time and reduces the risk of human error, allowing users to focus on what matters most: their applications.

---

This blog post serves as a comprehensive guide to understanding and utilizing the `kasten-validateaction` script effectively. For further details, refer to the script's documentation and the Kasten K10 user guide.