#!/usr/bin/env bash

# ============================================
# Fail fast on errors
# ============================================
set -e

# ============================================
# Usage helper
# ============================================
usage() {
  echo ""
  echo "Usage: ./runtests.sh [bvt|must|should|could|flaky] [@tag ...] [-@tag ...]"
  echo ""
  exit 1
}

# ============================================
# Validate and normalize tags
# ============================================
FIRST_ARG="$1"
RAW_TAGS=()

case "$FIRST_ARG" in
  bvt) RAW_TAGS+=("@bvt") ;;
  must) RAW_TAGS+=("@must") ;;
  should) RAW_TAGS+=("@should") ;;
  could) RAW_TAGS+=("@could") ;;
  flaky) RAW_TAGS+=("@flaky") ;;
  @*|-@*) RAW_TAGS+=("$FIRST_ARG") ;;
  *)
    echo "❌ Tag must start with @ (or -@ to exclude): $FIRST_ARG"
    usage
    ;;
esac

shift
for arg in "$@"; do
  if [[ "$arg" != @* && "$arg" != -@* ]]; then
    echo "❌ Tag must start with @ (or -@ to exclude): $arg"
    usage
  fi
  RAW_TAGS+=("$arg")
done

INCLUDE_TAGS=()
EXCLUDE_TAGS=()
for tag in "${RAW_TAGS[@]}"; do
  if [[ "$tag" == -@* ]]; then
    EXCLUDE_TAGS+=("${tag#-}")
  else
    INCLUDE_TAGS+=("$tag")
  fi
done

if [[ ${#INCLUDE_TAGS[@]} -eq 0 ]]; then
  echo "❌ At least one include tag is required (example: @bvt -@flaky)"
  usage
fi

GREP_TAGS_PARTS=()
for include_tag in "${INCLUDE_TAGS[@]}"; do
  expr="$include_tag"
  for exclude_tag in "${EXCLUDE_TAGS[@]}"; do
    expr="${expr}+-${exclude_tag}"
  done
  GREP_TAGS_PARTS+=("$expr")
done
GREP_TAGS="${GREP_TAGS_PARTS[*]}"

# ============================================
# Pretty output
# ============================================
echo ""
echo "======================================"
echo "🚀 Running Cypress tests"
echo "Input    : ${RAW_TAGS[*]}"
echo "grepTags : $GREP_TAGS"
echo "======================================"
echo ""

# ============================================
# Run Cypress (tag-based)
# ============================================
npx cypress run \
  --env grepTags="$GREP_TAGS",grepFilterSpecs=true,grepOmitFiltered=true \
  --browser chrome \
  --headed

# ============================================
# Success message
# ============================================
echo ""
echo "✅ Cypress finished successfully"
