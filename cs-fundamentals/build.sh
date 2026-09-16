#!/usr/bin/env bash
# ============================================================
#  Build the whole CS Fundamentals book to
#  ../pdf/4-cs-fundamentals.pdf
# ============================================================
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/book.typ"
OUT_DIR="$ROOT/../pdf"
OUT="$OUT_DIR/4-cs-fundamentals.pdf"

mkdir -p "$OUT_DIR"

if ! command -v typst >/dev/null 2>&1; then
  echo "error: typst not found on PATH" >&2
  exit 1
fi

echo "typst  : $(typst --version)"
echo "source : $SRC"
echo "output : $OUT"
echo

# --root / because the chapters import ../../shared/lib/style.typ,
# which lives outside this book's directory.
typst compile --root / "$SRC" "$OUT"

echo
echo "Built: $OUT"
echo "Size : $(du -h "$OUT" | cut -f1)"

# --- page count -------------------------------------------------
PAGES=""
if command -v pdfinfo >/dev/null 2>&1; then
  PAGES="$(pdfinfo "$OUT" 2>/dev/null | awk '/^Pages:/ {print $2}')"
elif command -v qpdf >/dev/null 2>&1; then
  PAGES="$(qpdf --show-npages "$OUT")"
elif command -v python3 >/dev/null 2>&1; then
  PAGES="$(python3 - "$OUT" <<'PY'
import re, sys
data = open(sys.argv[1], 'rb').read()
m = re.findall(rb'/Type\s*/Pages[^>]*?/Count\s+(\d+)', data)
print(max((int(x) for x in m), default=len(re.findall(rb'/Type\s*/Page[^s]', data))))
PY
)"
else
  PAGES="$(grep -a -c '/Type[[:space:]]*/Page[^s]' "$OUT" || true)"
fi

echo "Pages: ${PAGES:-unknown}"
