#!/usr/bin/env bash
# run-assay.sh — Wrapper for Assay codebase assessment
# Usage: run-assay.sh <project-path>
#
# Runs npx tryassay assess on the given project path.
# Output goes to <project-path>/.assay/

set -euo pipefail

[ -f "$HOME/Developer/.env" ] && set -a && source "$HOME/Developer/.env" && set +a

PROJECT_PATH="${1:-.}"

# Resolve to absolute path
PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"

if [ ! -d "$PROJECT_PATH" ]; then
  echo "Error: Directory not found: $PROJECT_PATH" >&2
  exit 1
fi

# Check if assessment already exists and is recent (< 7 days)
ASSESSMENT_DIR="$PROJECT_PATH/.assay"
if [ -d "$ASSESSMENT_DIR" ]; then
  SUMMARY="$ASSESSMENT_DIR/assessment-summary.json"
  if [ -f "$SUMMARY" ]; then
    # Get file age in days
    if [[ "$OSTYPE" == "darwin"* ]]; then
      FILE_AGE=$(( ( $(date +%s) - $(stat -f %m "$SUMMARY") ) / 86400 ))
    else
      FILE_AGE=$(( ( $(date +%s) - $(stat -c %Y "$SUMMARY") ) / 86400 ))
    fi

    if [ "$FILE_AGE" -lt 7 ]; then
      echo "EXISTING_ASSESSMENT:$ASSESSMENT_DIR"
      echo "AGE_DAYS:$FILE_AGE"
      exit 0
    else
      echo "STALE_ASSESSMENT:$ASSESSMENT_DIR"
      echo "AGE_DAYS:$FILE_AGE"
      exit 0
    fi
  fi
fi

echo "RUNNING_ASSESSMENT:$PROJECT_PATH"
npx tryassay assess --yes --no-publish "$PROJECT_PATH"

if [ -d "$ASSESSMENT_DIR" ]; then
  echo "ASSESSMENT_COMPLETE:$ASSESSMENT_DIR"
else
  echo "Error: Assessment completed but no output directory found" >&2
  exit 1
fi
