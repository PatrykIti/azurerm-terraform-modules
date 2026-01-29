#!/bin/bash
set -euo pipefail

SEARCH_DIRS=()
if [ -n "${TMPDIR:-}" ]; then
  SEARCH_DIRS+=("$TMPDIR")
fi
SEARCH_DIRS+=("/var/folders" "/tmp")

files=()
for dir in "${SEARCH_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    while IFS= read -r -d '' file; do
      files+=("$file")
    done < <(find "$dir" -type f -path "*/azurerm_log_analytics_workspace/tests/fixtures/*/.test-data/terraform-options.json" -print0 2>/dev/null)
  fi
done

if [ ${#files[@]} -eq 0 ]; then
  echo "No orphaned terraform options found."
  exit 0
fi

python3 - <<'PY' "${files[@]}"
import json
import subprocess
import sys

paths = sys.argv[1:]
seen_dirs = set()

for path in paths:
    try:
        with open(path, "r", encoding="utf-8") as fh:
            data = json.load(fh)
    except Exception:
        continue

    tfdir = data.get("TerraformDir")
    if not tfdir or tfdir in seen_dirs:
        continue
    seen_dirs.add(tfdir)

    vars_map = data.get("Vars") or {}

    args = [
        "terraform",
        f"-chdir={tfdir}",
        "destroy",
        "-auto-approve",
        "-input=false",
        "-lock=false",
        "-no-color",
    ]

    for key, value in vars_map.items():
        if value is None:
            continue
        if isinstance(value, bool):
            rendered = "true" if value else "false"
        elif isinstance(value, (int, float)):
            rendered = str(value)
        else:
            rendered = json.dumps(str(value))
        args.extend(["-var", f"{key}={rendered}"])

    print(f"Running cleanup for {tfdir}")
    subprocess.run(args, check=False)
PY
