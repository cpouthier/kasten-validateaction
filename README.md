# kasten-validateaction

## Overview

A ValidateAction resource (introduced in Kasten 8.0.5 - see https://docs.kasten.io/latest/api/actions#api-validate-action) validates backup data and metadata associated with a given Restore Point. Restore points exported using Filesystem mode can use the validate action to check the volume data exported for that restore point.

This Bash script automates validation of the **latest Kasten RestorePoint** in a Kubernetes cluster.  
It lists all namespaces, lets you select one, retrieves the most recent RestorePoint, creates a `ValidateAction` to verify data integrity, monitors the validation job in real time, and finally displays detailed results (then deletes the ValidateAction if no errors occurred).

---

## Features

- ✅ Lists available namespaces  
- ✅ Detects the latest RestorePoint automatically  
- ✅ Prompts for percentage of data to verify  
- ✅ Creates and monitors a ValidateAction until completion  
- ✅ Displays full validation results (phase, per-volume stats, errors)  
- ✅ Deletes the ValidateAction automatically if successful  

---

## Requirements

| Component | Description |
|------------|-------------|
| **kubectl** | Must be configured and authenticated with your cluster |
| **jq** | For parsing JSON output |
| **column** | For clean, aligned tables |
| **Kasten K10** | Installed in the cluster (for RestorePoint & ValidateAction CRDs) |

Make sure your user/service account has permissions to:
- List and get `restorepoints.apps.kio.kasten.io`
- Create and get `validateaction.actions.kio.kasten.io`

---

## Usage

```bash
chmod +x validateaction.sh
./validateaction.sh
```

Example output:
```
=== Available namespaces ===
default
wordpress
kasten-io
============================

Enter the concerned namespace: wordpress
🔍 Searching for the latest RestorePoint in namespace 'wordpress'...

✅ Latest RestorePoint in 'wordpress': scheduled-czqcd9ngj2

NAME                 CREATED                      EXPORT_PROFILE
scheduled-czqcd9ngj2 2025-10-20T00:01:06Z         locationprofile

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

---

## Notes

- The script automatically deletes the ValidateAction if there are no errors.  
- If you prefer to keep the ValidateAction for auditing, comment out the delete command at the end:
  ```bash
  # kubectl delete validateaction.actions.kio.kasten.io "$VALIDATE_NAME" -n kasten-io
  ```
- You can adjust the monitoring refresh rate by editing:
  ```bash
  sleep 1
  ```

---

## Troubleshooting

| Issue | Cause | Fix |
|-------|--------|-----|
| `jq: command not found` | jq not installed | Install with `apt install jq` or `brew install jq` |
| `No RestorePoint found` | No backups exist for the namespace | Run a backup first |
| ValidateAction stays in Running | Large data set or slow cluster | Wait longer or increase polling interval |
| CRDs not found | Kasten K10 not installed or not ready | Verify `kubectl get crds | grep kasten` |

---

## Example Flow Diagram

```
┌────────────────┐
│ Choose Namespace│
└──────┬─────────┘
       │
       ▼
┌──────────────────────────┐
│ Get Latest RestorePoint  │
└──────┬───────────────────┘
       │
       ▼
┌─────────────────────────────┐
│ Create ValidateAction (YAML)│
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│ Monitor Until Complete/Fail │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│ Display Validation Results  │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│ Delete ValidateAction (if OK)│
└─────────────────────────────┘
```

---

## License

This script is provided as-is, without warranty of any kind.  
You may freely modify or redistribute it for internal or personal use.
