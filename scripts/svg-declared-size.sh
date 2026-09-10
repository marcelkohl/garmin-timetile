#!/usr/bin/env bash
# Print declared intrinsic WxH for an SVG (width/height, else viewBox size).
# Usage: svg-declared-size.sh path/to/file.svg
set -euo pipefail

SRC="${1:?SVG path required}"
if [ ! -f "$SRC" ]; then
  echo "ERROR: SVG not found: $SRC" >&2
  exit 1
fi

python3 - "$SRC" <<'PY'
import re, sys
from pathlib import Path

src = Path(sys.argv[1])
text = src.read_text(encoding="utf-8", errors="replace")
m = re.search(r"<svg\b[^>]*>", text, re.I | re.S)
if not m:
    print(f"ERROR: {src}: no root <svg> element", file=sys.stderr)
    sys.exit(1)
tag = m.group(0)

def attr(name):
    mm = re.search(rf'\b{name}\s*=\s*"([^"]*)"', tag, re.I)
    if mm:
        return mm.group(1).strip()
    mm = re.search(rf"\b{name}\s*=\s*'([^']*)'", tag, re.I)
    return mm.group(1).strip() if mm else None

def parse_px(raw, label):
    if raw is None:
        return None
    s = raw.strip()
    if s.endswith("%"):
        print(f"ERROR: {src}: {label} '{raw}' is percentage-based; need pixel size", file=sys.stderr)
        sys.exit(1)
    # Accept 25 or 25px only.
    m = re.fullmatch(r"([0-9]+(?:\.[0-9]+)?)([a-zA-Z]*)", s)
    if not m:
        print(f"ERROR: {src}: {label} '{raw}' is not a pixel length", file=sys.stderr)
        sys.exit(1)
    num, unit = m.group(1), m.group(2).lower()
    if unit not in ("", "px"):
        print(
            f"ERROR: {src}: {label} '{raw}' uses unsupported unit; need pixels (e.g. 25 or 25px)",
            file=sys.stderr,
        )
        sys.exit(1)
    px = int(float(num))
    if px <= 0:
        print(f"ERROR: {src}: {label} '{raw}' must be positive", file=sys.stderr)
        sys.exit(1)
    return px

w = parse_px(attr("width"), "width")
h = parse_px(attr("height"), "height")
if w is not None and h is not None:
    print(f"{w}x{h}")
    sys.exit(0)

vb = attr("viewBox")
if not vb:
    print(f"ERROR: {src}: missing pixel width/height and viewBox", file=sys.stderr)
    sys.exit(1)
parts = vb.replace(",", " ").split()
if len(parts) != 4:
    print(f"ERROR: {src}: invalid viewBox '{vb}'", file=sys.stderr)
    sys.exit(1)
vw = parse_px(parts[2], "viewBox width")
vh = parse_px(parts[3], "viewBox height")
print(f"{vw}x{vh}")
PY
