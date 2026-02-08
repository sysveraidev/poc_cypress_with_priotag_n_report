#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
report_dir="$root_dir/cypress/reports"

report="${REPORT_PATH:-}"
if [[ -n "${report}" ]]; then
  if [[ ! -f "$report" ]]; then
    echo "Report not found at REPORT_PATH=$report" >&2
    exit 1
  fi
else
  candidates=()
  if [[ -d "$report_dir" ]]; then
    while IFS= read -r -d '' f; do
      candidates+=("$f")
    done < <(find "$report_dir" -type f -name "*.html" -print0)
  fi

  if [[ ${#candidates[@]} -eq 0 ]]; then
    echo "No Cypress HTML report found in $report_dir." >&2
    echo "Run tests first (for example: ./runtests.sh bvt), then run ./open-report.sh." >&2
    echo "Or set REPORT_PATH to a specific report file." >&2
    exit 1
  fi

  report="$(ls -t "${candidates[@]}" 2>/dev/null | head -n 1)"
fi

echo "Opening report: $report"
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$report" >/dev/null 2>&1 &
elif command -v open >/dev/null 2>&1; then
  open "$report" >/dev/null 2>&1 &
else
  echo "No opener found. Open manually: $report" >&2
  exit 1
fi
