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
  echo "Usage: ./run-cypress.sh [bvt|must|should|could|flaky]"
  echo ""
  exit 1
}

# ============================================
# Validate argument
# ============================================
PRIORITY="$1"

if [[ -z "$PRIORITY" ]]; then
  usage
fi

# ============================================
# Map priority → tag
# ============================================
case "$PRIORITY" in
  bvt)
    TAG="@bvt"
    ;;
  must)
    TAG="@must"
    ;;
  should)
    TAG="@should"
    ;;
  could)
    TAG="@could"
    ;;
  flaky)
    TAG="@flaky"
    ;;
  *)
    echo "❌ Invalid priority: $PRIORITY"
    usage
    ;;
esac

# ============================================
# Pretty output
# ============================================
echo ""
echo "======================================"
echo "🚀 Running Cypress tests"
echo "Priority : $PRIORITY"
echo "Tag      : $TAG"
echo "======================================"
echo ""

# ============================================
# Run Cypress (tag-based)
# ============================================
npx cypress run \
  --env grepTags="$TAG",grepFilterSpecs=true,grepOmitFiltered=true \
  --browser chrome \
  --headed

# ============================================
# Success message
# ============================================
echo ""
echo "✅ Cypress finished successfully"
