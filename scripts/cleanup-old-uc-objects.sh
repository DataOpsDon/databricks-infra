#!/usr/bin/env bash
# Deletes the old Unity Catalog objects left in the spoke workspace after the
# databricks_workspace Terraform state was cleared. They block the renamed
# external locations and catalogs (Databricks rejects overlapping storage paths).
#
# DESTRUCTIVE: --force also deletes any schemas and tables inside the catalogs.
#
# Usage: scripts/cleanup-old-uc-objects.sh [-p <databricks-cli-profile>] [-y]
#   -p  Databricks CLI profile for the spoke workspace (default: DEFAULT)
#   -y  skip the confirmation prompt

set -euo pipefail

PROFILE="adb-7405619318376778"
ASSUME_YES="false"

while getopts "p:y" opt; do
  case "$opt" in
    p) PROFILE="$OPTARG" ;;
    y) ASSUME_YES="true" ;;
    *) echo "Usage: $0 [-p profile] [-y]" >&2; exit 2 ;;
  esac
done

command -v databricks >/dev/null || { echo "databricks CLI not found" >&2; exit 1; }

CATALOGS=(bronze-dev silver-dev gold-dev)
EXTERNAL_LOCATIONS=(ext-bronze-dev ext-silver-dev ext-gold-dev)
STORAGE_CREDENTIALS=(sc-edp-dev-uks)

echo "Workspace profile: ${PROFILE}"
echo "Will delete (with --force):"
printf '  catalog:             %s\n' "${CATALOGS[@]}"
printf '  external location:   %s\n' "${EXTERNAL_LOCATIONS[@]}"
printf '  storage credential:  %s\n' "${STORAGE_CREDENTIALS[@]}"

if [[ "$ASSUME_YES" != "true" ]]; then
  read -r -p "Type 'yes' to continue: " answer
  [[ "$answer" == "yes" ]] || { echo "Aborted."; exit 1; }
fi

# Delete in dependency order: catalogs, then external locations, then credentials.
# A missing object is reported and skipped so the script can be re-run.
delete() {
  local kind="$1" name="$2"
  if databricks "$kind" delete "$name" --force --profile "$PROFILE"; then
    echo "deleted ${kind}: ${name}"
  else
    echo "skipped ${kind}: ${name} (not found or delete failed)" >&2
  fi
}

for name in "${CATALOGS[@]}"; do delete catalogs "$name"; done
for name in "${EXTERNAL_LOCATIONS[@]}"; do delete external-locations "$name"; done
for name in "${STORAGE_CREDENTIALS[@]}"; do delete storage-credentials "$name"; done

echo "Done. Re-run the databricks_workspace apply."
