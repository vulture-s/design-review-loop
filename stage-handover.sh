#!/usr/bin/env bash
# stage-handover.sh — Stage a design-review handover pack to the Desktop for web upload.
#
# The web design agent runs in a SANDBOX: it cannot read this machine's disk,
# it REJECTS .zip, and it only accepts a FLAT file list (see
# references/web-sandbox-limits.md). So a path or a zip is useless for the actual
# upload — the user must drag LOOSE files into the web uploader. This script
# produces exactly that: a flat folder of web-acceptable files + a stitched
# single-file bundle, plus an optional zip for transfer/backup.
#
# Usage:
#   bash stage-handover.sh <source-dir> [dest-name] [--zip] [--dry-run]
#
#   <source-dir>  dir to gather briefs + screenshots from (recursive)
#   [dest-name]   Desktop folder name (default: basename of source-dir)
#   --zip         also produce ~/Desktop/<dest-name>.zip (transfer/backup only)
#   --dry-run     print what would be staged, copy nothing
#
# Example:
#   bash stage-handover.sh ./audit/2026-01-15-mobile-rebuild mobile-handover --zip

set -euo pipefail

# --- args ---
SRC="${1:-}"
[[ -n "$SRC" && -d "$SRC" ]] || { echo "ERROR: source dir missing or not a dir: '${SRC:-<none>}'"; exit 1; }
SRC="$(cd "$SRC" && pwd)"

DEST_NAME="${2:-}"
case "$DEST_NAME" in ""|--zip|--dry-run) DEST_NAME="$(basename "$SRC")-handover" ;; esac

DO_ZIP=false; DRY=false
for a in "$@"; do
  [[ "$a" == "--zip" ]] && DO_ZIP=true
  [[ "$a" == "--dry-run" ]] && DRY=true
done

# Where to stage. Defaults to the Desktop (so the user can drag files into the web
# uploader); override with DEST_BASE for headless/CI/test runs.
DEST_BASE="${DEST_BASE:-$HOME/Desktop}"
mkdir -p "$DEST_BASE"
DEST="$DEST_BASE/$DEST_NAME"

# web-acceptable extensions (per claude-ai-web-limits.md). Everything else is
# silently skipped — fonts/svg/zip/afdesign are rejected by claude.ai anyway.
ACCEPT_RE='\.(md|txt|json|ya?ml|csv|png|jpe?g|webp|pdf|py|js|ts|tsx|html|css)$'

# gather (recursive, flat output). NUL-safe for spaces. bash 3.2 compatible
# (no mapfile) so it runs on stock macOS /bin/bash.
STAGE=()
while IFS= read -r -d '' f; do
  [[ "$(basename "$f")" == .* ]] && continue          # skip dotfiles
  [[ "$f" =~ $ACCEPT_RE ]] && STAGE+=("$f")
done < <(find "$SRC" -type f -print0)
[[ ${#STAGE[@]} -gt 0 ]] || { echo "ERROR: no web-acceptable files found under $SRC"; exit 1; }

echo "Source : $SRC"
echo "Dest   : $DEST"
echo "Staging ${#STAGE[@]} file(s):"
for f in "${STAGE[@]}"; do echo "  + ${f#$SRC/}"; done

if $DRY; then
  echo "[dry-run] no files copied."
  $DO_ZIP && echo "[dry-run] would also write $DEST.zip"
  exit 0
fi

# --- build ---
rm -rf "$DEST" "$DEST.zip"
mkdir -p "$DEST"

# flatten copy + detect name collisions (flat upload can't have dupes).
# bash 3.2 compatible: test dest existence instead of an associative array.
for f in "${STAGE[@]}"; do
  b="$(basename "$f")"
  if [[ -e "$DEST/$b" ]]; then
    # prefix with parent dir to disambiguate
    b="$(basename "$(dirname "$f")")__$b"
    echo "  ! collision → renamed to $b"
  fi
  cp "$f" "$DEST/$b"
done

# stitch all .md into one read-first bundle (copy-paste friendly)
BUNDLE="$DEST/00-READ-FIRST-bundle.md"
{
  echo "# Handover Bundle — $DEST_NAME"
  echo
  echo "> Auto-stitched by stage-handover.sh. Loose files in this folder are for"
  echo "> drag-upload to claude.ai (web cannot read disk, rejects zip). This bundle"
  echo "> concatenates every .md below for quick copy-paste."
  echo
  echo "## Contents"
  for f in "$DEST"/*.md; do
    [[ "$(basename "$f")" == "00-READ-FIRST-bundle.md" ]] && continue
    echo "- $(basename "$f")"
  done
  for f in "$DEST"/*.md; do
    bn="$(basename "$f")"
    [[ "$bn" == "00-READ-FIRST-bundle.md" ]] && continue
    echo
    echo "═══════════════════════════════════════════════"
    echo "# $bn"
    echo "═══════════════════════════════════════════════"
    echo
    cat "$f"
  done
} > "$BUNDLE"

echo "✓ Staged → $DEST  ($(ls -1 "$DEST" | wc -l | tr -d ' ') files, bundle = 00-READ-FIRST-bundle.md)"

if $DO_ZIP; then
  ( cd "$DEST_BASE" && zip -rq "$DEST_NAME.zip" "$DEST_NAME" )
  echo "✓ Zipped → $DEST.zip  (transfer/backup only — do NOT upload the zip to claude.ai)"
fi

echo
echo "NEXT: drag the LOOSE files (not the zip) into the claude.ai uploader."
echo "      Open the bundle to copy-paste the briefs:  open \"$BUNDLE\""
