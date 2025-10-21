#!/bin/bash
set -euo pipefail

echo "=== Available namespaces ==="
kubectl get ns --no-headers -o custom-columns=":metadata.name"
echo "============================"
echo

read -rp "Enter the concerned namespace: " NS

# Validate namespace exists
if ! kubectl get ns "$NS" &>/dev/null; then
  echo "❌ Namespace '$NS' does not exist."
  exit 1
fi

echo
echo "🔍 Searching for the latest RestorePoint in namespace '$NS'..."
echo

# Find latest RestorePoint by creationTimestamp
LATEST_RP=$(
  kubectl get restorepoints.apps.kio.kasten.io -n "$NS" \
    --sort-by=.metadata.creationTimestamp \
    -o jsonpath='{.items[-1:].metadata.name}'
)

if [[ -z "${LATEST_RP:-}" ]]; then
  echo "⚠️  No RestorePoint found in namespace '$NS'."
  exit 0
fi

echo "✅ Latest RestorePoint in '$NS': $LATEST_RP"
echo

# Display details with EXPORT_PROFILE column (from labels)
{
  printf "NAME\tCREATED\tEXPORT_PROFILE\n"
  kubectl get restorepoints.apps.kio.kasten.io "$LATEST_RP" -n "$NS" -o json \
    | jq -r '[.metadata.name,
              .metadata.creationTimestamp,
              .metadata.labels["k10.kasten.io/exportProfile"]] | @tsv'
} | column -t -s $'\t'



# Check that $LATEST_RP and $NS are defined
if [[ -z "${LATEST_RP:-}" || -z "${NS:-}" ]]; then
  echo "❌ Variables LATEST_RP and NS must be set before running this script."
  echo "Example:"
  echo "  export LATEST_RP=scheduled-czqcd9ngj2"
  echo "  export NS=wordpress"
  exit 1
fi

echo ""
echo "" 
# Ask for verifyFilesPercent value
read -rp "Enter percentage of files to verify (1–100): " PCT
if ! [[ "$PCT" =~ ^[0-9]+$ ]] || [ "$PCT" -lt 1 ] || [ "$PCT" -gt 100 ]; then
  echo "❌ Invalid percentage value. Must be 1–100."
  exit 1
fi

# Create temporary YAML
TMP_FILE=$(mktemp)
cat > "$TMP_FILE" <<EOF
apiVersion: actions.kio.kasten.io/v1alpha1
kind: ValidateAction
metadata:
  generateName: validate-sample-app-
  namespace: kasten-io
spec:
  volumeDataCheckOptions:
    verifyFilesPercent: "$PCT"
    failFast: false
  subject:
    kind: RestorePoint
    name: $LATEST_RP
    namespace: $NS
EOF

echo "✅ Creating ValidateAction for restore point '$LATEST_RP'..."
echo

# Create the ValidateAction and capture its generated name
VALIDATE_NAME=$(kubectl create -f "$TMP_FILE" -n kasten-io -o jsonpath='{.metadata.name}')

rm -f "$TMP_FILE"

echo "✅ ValidateAction successfully created:"
echo "   → Name: $VALIDATE_NAME"
echo "   → Namespace: kasten-io"
echo "   → verifyFilesPercent: $PCT"
echo

echo "⏳ Monitoring progress (refresh every 1s)..."
echo "NAME	STATE	CREATED"

# Loop until state is Complete or Failed
while true; do
  STATUS=$(kubectl get validateaction.actions.kio.kasten.io "$VALIDATE_NAME" -n kasten-io \
    -o jsonpath='{.status.state}' 2>/dev/null || echo "Unknown")
  CREATED=$(kubectl get validateaction.actions.kio.kasten.io "$VALIDATE_NAME" -n kasten-io \
    -o jsonpath='{.metadata.creationTimestamp}' 2>/dev/null || echo "-")
  printf "\r%-40s %-12s %s" "$VALIDATE_NAME" "$STATUS" "$CREATED"

  if [[ "$STATUS" == "Complete" || "$STATUS" == "Failed" ]]; then
    echo -e "\n\n✅ ValidateAction finished with status: $STATUS"
    break
  fi
  sleep 1
done

# ── Fetch and display action details ──────────────────────────
echo "===== Action Details ====="
DETAILS_JSON=$(kubectl get --raw "/apis/actions.kio.kasten.io/v1alpha1/namespaces/kasten-io/validateactions/$VALIDATE_NAME/details")

ERROR_COUNT=$(jq -r '.status.actionDetails.errorCount // 0' <<<"$DETAILS_JSON")

echo "ATTEMPT	STATE	START			END"
jq -r '.status.actionDetails.phases[]? | [.attempt, .state, .startTime, .endTime] | @tsv' <<<"$DETAILS_JSON" | column -t -s $'\t'
echo

echo "APP	VOLUME	ERRCOUNT	READ_FILES	READ_BYTES"
jq -r '
  (.status.actionDetails.volumeDataCheckResult // [])[]
  | [
      (.appName // "-"),
      (.volumeName // "-"),
      (.errCount // 0),
      (.stats.readFileCount // 0),
      (.stats.readBytes // 0)
    ] | @tsv' <<<"$DETAILS_JSON" | column -t -s $'\t'
echo

if (( ERROR_COUNT > 0 )); then
  echo "Errors ($ERROR_COUNT):"
  jq -r '
    (.status.actionDetails.volumeDataCheckResult // [])[]
    | select((.errCount // 0) > 0)
    | . as $v
    | ($v.errors // [])[]
    | "\($v.appName // "-")/\($v.volumeName // "-"): " + .
  ' <<<"$DETAILS_JSON"
else
  kubectl get --raw /apis/actions.kio.kasten.io/v1alpha1/namespaces/kasten-io/validateactions/$VALIDATE_NAME/details | jq

  kubectl delete validateaction.actions.kio.kasten.io "$VALIDATE_NAME" -n kasten-io
  echo ""
  echo "No errors reported (errorCount=0)."
  echo ""
fi
