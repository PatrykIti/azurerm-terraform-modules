#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export REPO_ROOT

python3 - <<'PY'
from pathlib import Path
import os
import re
import sys

root = Path(os.environ["REPO_ROOT"])
tasks_dir = root / "docs" / "_TASKS"
readme_path = tasks_dir / "README.md"

errors = []

task_files = sorted(tasks_dir.glob("TASK-*.md"))
if not task_files:
    errors.append("No TASK files found in docs/_TASKS.")

for path in task_files:
    text = path.read_text(encoding="utf-8").splitlines()
    if not text:
        errors.append(f"{path.name}: empty file")
        continue
    expected_id = path.name.split("_", 1)[0]
    if not text[0].startswith(f"# {expected_id}:"):
        errors.append(f"{path.name}: header mismatch (expected '# {expected_id}:')")
    file_line = next((l for l in text[1:6] if l.startswith("# FileName: ")), None)
    if not file_line:
        errors.append(f"{path.name}: missing FileName line")
    else:
        actual_fname = file_line.replace("# FileName: ", "").strip()
        if actual_fname != path.name:
            errors.append(f"{path.name}: FileName line mismatch ({actual_fname})")

number_map = {}
for path in task_files:
    if path.name.startswith("TASK-ADO-"):
        continue
    match = re.match(r"TASK-(\d{3})_", path.name)
    if not match:
        continue
    number_map.setdefault(match.group(1), []).append(path.name)

for num, files in sorted(number_map.items()):
    if len(files) > 1:
        errors.append(f"Duplicate TASK-{num} files: {', '.join(sorted(files))}")

if readme_path.exists():
    readme = readme_path.read_text(encoding="utf-8")
    count_match = re.search(r"^- \*\*To Do:\*\* (\d+) tasks", readme, re.M)
    if not count_match:
        errors.append("docs/_TASKS/README.md: missing To Do count")
    else:
        declared = int(count_match.group(1))
        lines = readme.splitlines()
        try:
            start = lines.index("## To Do")
            end = lines.index("## In Progress")
            rows = [l for l in lines[start:end] if l.startswith("| [TASK-")]
            if declared != len(rows):
                errors.append(
                    f"docs/_TASKS/README.md: To Do count mismatch (declared {declared}, actual {len(rows)})"
                )
        except ValueError:
            errors.append("docs/_TASKS/README.md: missing '## To Do' or '## In Progress' sections")

    links = re.findall(r"\\(\\./(TASK-[^)]+\\.md)\\)", readme)
    missing = [l for l in links if not (tasks_dir / l).exists()]
    if missing:
        errors.append(f"docs/_TASKS/README.md: broken links: {', '.join(missing)}")
else:
    errors.append("docs/_TASKS/README.md not found")

if errors:
    print("Task checks failed:")
    for err in errors:
        print(f"- {err}")
    sys.exit(1)

print("Task checks passed.")
PY
