#!/usr/bin/env bash
# Render one icon base SVG to OnLight + OnDark PNGs (colors preserved).
# Usage: render-svg-contrast-pair.sh <base.svg> <on_light.png> <on_dark.png>
#
# Optional dark source: same path with _on_dark.svg before .svg
# e.g. steps.svg -> steps_on_dark.svg
set -euo pipefail

BASE_SVG="${1:?base SVG required}"
OUT_LIGHT="${2:?on_light PNG required}"
OUT_DARK="${3:?on_dark PNG required}"
SVG_SIZE_HELPER="${SVG_SIZE:-scripts/svg-declared-size.sh}"

if ! command -v convert >/dev/null 2>&1; then
  echo "ERROR: ImageMagick 'convert' not found on PATH."
  echo "Install on Ubuntu: sudo apt install imagemagick"
  exit 1
fi

if [ ! -f "$BASE_SVG" ]; then
  echo "ERROR: SVG not found: $BASE_SVG"
  exit 1
fi

if [ ! -x "$SVG_SIZE_HELPER" ]; then
  chmod +x "$SVG_SIZE_HELPER"
fi

# Derive optional dark SVG path: foo.svg -> foo_on_dark.svg
DARK_SVG="$(echo "$BASE_SVG" | sed 's/\.svg$/_on_dark.svg/')"

mkdir -p "$(dirname "$OUT_LIGHT")" "$(dirname "$OUT_DARK")"

# ImageMagick rejects invalid attribute values such as opacity="undefined"
# (common editor residue). Render from a temp copy with those stripped —
# never rewrite the user's source SVG.
prepare_svg_for_convert() {
  local src="$1"
  local dest="$2"
  # Drop opacity="undefined" / opacity='undefined' only; keep all other artwork.
  sed -E 's/[[:space:]]opacity=("|\x27)undefined\1//g' "$src" > "$dest"
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

declared="$("$SVG_SIZE_HELPER" "$BASE_SVG")"
echo "Generating $OUT_LIGHT (intrinsic $declared) from $BASE_SVG..."
TMP_BASE="$TMP_DIR/base.svg"
prepare_svg_for_convert "$BASE_SVG" "$TMP_BASE"
convert -background none "$TMP_BASE" PNG32:"$OUT_LIGHT"

got="$(identify -format '%wx%h' "$OUT_LIGHT")"
if [ "$got" != "$declared" ]; then
  echo "ERROR: $BASE_SVG declares $declared"
  echo "but generated $OUT_LIGHT is $got"
  exit 1
fi

opaque="$(convert "$OUT_LIGHT" -alpha extract -format '%[fx:maxima]' info:)"
opaque_int="$(echo "$opaque" | awk '{printf "%d", ($1>0)?1:0}')"
if [ "$opaque_int" -le 0 ]; then
  echo "ERROR: $OUT_LIGHT is completely transparent (from $BASE_SVG)"
  exit 1
fi

if [ -f "$DARK_SVG" ]; then
  dark_declared="$("$SVG_SIZE_HELPER" "$DARK_SVG")"
  if [ "$dark_declared" != "$declared" ]; then
    echo "ERROR: $DARK_SVG declares $dark_declared but base $BASE_SVG declares $declared"
    echo "       Explicit OnDark artwork must match base width and height."
    exit 1
  fi

  # viewBox proportion check (width/height of viewBox must match when both present)
  python3 - "$BASE_SVG" "$DARK_SVG" <<'PY'
import re, sys
from pathlib import Path

def viewbox(path):
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    m = re.search(r"<svg\b[^>]*>", text, re.I | re.S)
    if not m:
        return None
    tag = m.group(0)
    mm = re.search(r'\bviewBox\s*=\s*"([^"]*)"', tag, re.I)
    if not mm:
        mm = re.search(r"\bviewBox\s*=\s*'([^']*)'", tag, re.I)
    if not mm:
        return None
    parts = mm.group(1).replace(",", " ").split()
    if len(parts) != 4:
        return None
    try:
        return (float(parts[2]), float(parts[3]))
    except ValueError:
        return None

base, dark = sys.argv[1], sys.argv[2]
vb_b, vb_d = viewbox(base), viewbox(dark)
if vb_b and vb_d:
    # Match proportions within a small epsilon.
    if abs(vb_b[0] - vb_d[0]) > 0.01 or abs(vb_b[1] - vb_d[1]) > 0.01:
        print(
            f"ERROR: {dark} viewBox size {vb_d[0]}x{vb_d[1]} "
            f"does not match base {base} viewBox {vb_b[0]}x{vb_b[1]}",
            file=sys.stderr,
        )
        sys.exit(1)
PY

  echo "Generating $OUT_DARK (intrinsic $dark_declared) from $DARK_SVG..."
  TMP_DARK="$TMP_DIR/dark.svg"
  prepare_svg_for_convert "$DARK_SVG" "$TMP_DARK"
  convert -background none "$TMP_DARK" PNG32:"$OUT_DARK"
  dark_got="$(identify -format '%wx%h' "$OUT_DARK")"
  if [ "$dark_got" != "$declared" ]; then
    echo "ERROR: $DARK_SVG / $OUT_DARK size $dark_got does not match base $declared"
    exit 1
  fi
  dark_opaque="$(convert "$OUT_DARK" -alpha extract -format '%[fx:maxima]' info:)"
  dark_opaque_int="$(echo "$dark_opaque" | awk '{printf "%d", ($1>0)?1:0}')"
  if [ "$dark_opaque_int" -le 0 ]; then
    echo "ERROR: $OUT_DARK is completely transparent (from $DARK_SVG)"
    exit 1
  fi
else
  base_name="$(basename "$BASE_SVG")"
  dark_name="$(basename "$DARK_SVG")"
  echo "INFO: $dark_name not found; reusing $base_name"
  # Byte-identical fallback copy (no re-encode).
  cp -f "$OUT_LIGHT" "$OUT_DARK"
  if ! cmp -s "$OUT_LIGHT" "$OUT_DARK"; then
    echo "ERROR: fallback OnDark copy is not byte-identical to OnLight for $BASE_SVG"
    exit 1
  fi
fi

light_wh="$(identify -format '%wx%h' "$OUT_LIGHT")"
dark_wh="$(identify -format '%wx%h' "$OUT_DARK")"
if [ "$light_wh" != "$dark_wh" ]; then
  echo "ERROR: OnLight $light_wh and OnDark $dark_wh dimensions differ for $BASE_SVG"
  exit 1
fi

# Soft check: unique opaque RGB samples from OnLight (informational / fail if none).
python3 - "$OUT_LIGHT" "$BASE_SVG" <<'PY'
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    sys.exit(0)

png_path, svg_path = Path(sys.argv[1]), Path(sys.argv[2])
im = Image.open(png_path).convert("RGBA")
colors = set()
for r, g, b, a in im.getdata():
    if a > 0:
        colors.add((r, g, b))
if not colors:
    print(f"ERROR: {png_path} has no visible (opaque) RGB colors", file=sys.stderr)
    sys.exit(1)

text = svg_path.read_text(encoding="utf-8", errors="replace").lower()
need_black = ("#000" in text or "#000000" in text or '="black"' in text
              or "fill=\"black\"" in text or "stroke=\"black\"" in text)
need_white = ("#fff" in text or "#ffffff" in text or '="white"' in text
              or "fill=\"white\"" in text or "stroke=\"white\"" in text)

def has_near(target, tol=8):
    tr, tg, tb = target
    for r, g, b in colors:
        if abs(r - tr) <= tol and abs(g - tg) <= tol and abs(b - tb) <= tol:
            return True
    return False

missing = []
if need_black and not has_near((0, 0, 0)):
    missing.append("black")
if need_white and not has_near((255, 255, 255)):
    missing.append("white")
if missing:
    print(
        f"ERROR: OnLight {png_path.name} missing expected source colors {missing}; "
        f"sample RGB {sorted(colors)[:16]}{'...' if len(colors) > 16 else ''}",
        file=sys.stderr,
    )
    sys.exit(1)
PY

echo "OK: $BASE_SVG -> $light_wh on_light / on_dark"
