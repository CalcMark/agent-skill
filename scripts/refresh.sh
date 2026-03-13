#!/usr/bin/env bash
#
# Regenerate platform skill files from CALCMARK-AGENT.md.
#
# Usage:
#   ./scripts/refresh.sh           # write files
#   ./scripts/refresh.sh --check   # exit 1 if any file is out of date
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BODY="$ROOT/CALCMARK-AGENT.md"
CHECK=false

[[ "${1:-}" == "--check" ]] && CHECK=true

# --- Platform definitions ------------------------------------------------
# Each entry: output_path|frontmatter_file_function
# Claude Code is maintained separately (different body, WebFetch-based).

platforms=(
  "platforms/cursor/.cursor/rules/calcmark.mdc|cursor"
  "platforms/copilot-cli/.github/skills/calcmark/SKILL.md|copilot"
  "platforms/gemini-cli/.gemini/skills/calcmark/SKILL.md|gemini"
)

frontmatter_cursor() {
  cat <<'FM'
---
description: "Use CalcMark CLI for calculations, unit conversions, date arithmetic, and computational documents. Activate for cost modeling, capacity planning, budgets, napkin math, or any quantitative analysis."
globs: ["**/*.cm"]
alwaysApply: false
---
FM
}

frontmatter_copilot() {
  cat <<'FM'
---
name: calcmark
description: "Provides expertise in CalcMark (.cm) documents -- a language that blends CommonMark markdown with inline calculations. Use for cost modeling, capacity planning, unit conversions, date arithmetic, budgets, napkin math, and quantitative analysis."
license: MIT
---
FM
}

frontmatter_gemini() {
  cat <<'FM'
---
name: calcmark
description: >
  Use this skill when working with CalcMark (.cm) files or performing quantitative analysis.
  CalcMark blends CommonMark markdown with inline calculations for cost modeling,
  capacity planning, unit conversions, date arithmetic, napkin math, and budgets.
---
FM
}

# --- Helpers -------------------------------------------------------------

generate() {
  local platform="$1"
  { frontmatter_"${platform}"; cat "$BODY"; }
}

# --- Generate / Check ----------------------------------------------------

errors=0

for entry in "${platforms[@]}"; do
  outpath="${entry%%|*}"
  platform="${entry##*|}"
  full_path="$ROOT/$outpath"

  if $CHECK; then
    if [[ ! -f "$full_path" ]]; then
      echo "MISSING: $outpath"
      errors=$((errors + 1))
    elif ! diff -q <(generate "$platform") "$full_path" > /dev/null 2>&1; then
      echo "OUT OF DATE: $outpath"
      diff --unified <(generate "$platform") "$full_path" | head -20
      errors=$((errors + 1))
    else
      echo "OK: $outpath"
    fi
  else
    mkdir -p "$(dirname "$full_path")"
    generate "$platform" > "$full_path"
    echo "Wrote: $outpath"
  fi
done

# Claude Code: just verify it exists (maintained separately)
cc_path="platforms/claude-code/.claude/skills/calcmark/SKILL.md"
if [[ ! -f "$ROOT/$cc_path" ]]; then
  echo "MISSING: $cc_path (maintained separately)"
  errors=$((errors + 1))
else
  echo "OK: $cc_path (maintained separately)"
fi

if $CHECK && [[ $errors -gt 0 ]]; then
  echo ""
  echo "Run ./scripts/refresh.sh to fix."
  exit 1
fi
