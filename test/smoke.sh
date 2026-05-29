#!/usr/bin/env bash
# smoke.sh — minimal end-to-end check for stage-handover.sh
# Stages a fixture into a temp dir, then asserts the contract:
#   - web-acceptable files are flattened in
#   - rejected formats (fonts/zip/svg) are dropped
#   - the .md files are stitched into 00-READ-FIRST-bundle.md
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# fixture
mkdir -p "$TMP/src/sub"
printf '# Brief Alpha\nalpha body\n' > "$TMP/src/BRIEF-A.md"
printf '# Brief Beta\nbeta body\n'   > "$TMP/src/sub/BRIEF-B.md"   # nested → must flatten
printf 'PNGDATA'                      > "$TMP/src/shot.png"
printf 'FONTDATA'                     > "$TMP/src/font.woff2"       # rejected format
printf 'SVGDATA'                      > "$TMP/src/icon.svg"         # rejected format

# run (stage into temp, not the Desktop)
DEST_BASE="$TMP/out" bash "$HERE/stage-handover.sh" "$TMP/src" pack >/dev/null
OUT="$TMP/out/pack"

fails=0
ok()   { echo "  ✓ $1"; }
bad()  { echo "  ✗ $1"; fails=$((fails+1)); }
want() { if eval "$1"; then ok "$2"; else bad "$2"; fi; }

echo "smoke: stage-handover.sh"
want '[ -d "$OUT" ]'                                  "dest folder created"
want '[ -f "$OUT/BRIEF-A.md" ]'                        "top-level .md staged"
want '[ -f "$OUT/BRIEF-B.md" ]'                        "nested .md flattened in"
want '[ -f "$OUT/shot.png" ]'                          "image staged"
want '[ ! -f "$OUT/font.woff2" ]'                      "font (rejected fmt) dropped"
want '[ ! -f "$OUT/icon.svg" ]'                        "svg (rejected fmt) dropped"
want '[ -f "$OUT/00-READ-FIRST-bundle.md" ]'           "bundle generated"
want 'grep -q "Brief Alpha" "$OUT/00-READ-FIRST-bundle.md"' "bundle contains brief A"
want 'grep -q "Brief Beta"  "$OUT/00-READ-FIRST-bundle.md"' "bundle contains brief B"

# --dry-run must not write
DEST_BASE="$TMP/dry" bash "$HERE/stage-handover.sh" "$TMP/src" dpack --dry-run >/dev/null
want '[ ! -d "$TMP/dry/dpack" ]'                       "--dry-run writes nothing"

if [ "$fails" -eq 0 ]; then
  echo "PASS"
else
  echo "FAIL ($fails)"; exit 1
fi
