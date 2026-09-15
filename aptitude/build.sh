#!/usr/bin/env bash
# ============================================================
#  Build the whole book to build/aptitude-book.pdf
# ============================================================
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/book.typ"
OUT_DIR="$ROOT/build"
OUT="$OUT_DIR/aptitude-book.pdf"

mkdir -p "$OUT_DIR"

if ! command -v typst >/dev/null 2>&1; then
  echo "error: typst not found on PATH" >&2
  exit 1
fi

echo "typst  : $(typst --version)"
echo "source : $SRC"
echo "output : $OUT"
echo

typst compile --root "$ROOT" "$SRC" "$OUT"

echo
echo "Built: $OUT"
echo "Size : $(du -h "$OUT" | cut -f1)"

# --- page count -------------------------------------------------
PAGES=""
if command -v pdfinfo >/dev/null 2>&1; then
  PAGES="$(pdfinfo "$OUT" 2>/dev/null | awk '/^Pages:/ {print $2}')"
elif command -v qpdf >/dev/null 2>&1; then
  PAGES="$(qpdf --show-npages "$OUT")"
else
  PAGES="$(grep -a -c '/Type[[:space:]]*/Page[^s]' "$OUT" || true)"
fi

echo "Pages: ${PAGES:-unknown}"
