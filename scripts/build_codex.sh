#!/usr/bin/env bash
# Compile data/codex/*.md into one book. This is the ebook-DLC pipeline:
# the lore the game reads is the manuscript the book is built from.
# Markdown always; EPUB too if pandoc is installed.
set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=C.UTF-8 2>/dev/null || export LC_ALL=en_US.UTF-8
mkdir -p build

python3 - << 'PYEOF'
import glob, re, pathlib

# Pandoc metadata lives INSIDE the document, not on the command line —
# argv encoding depends on the machine's locale; file I/O is always UTF-8.
out = ['---',
       'title: "The Long Bronze — A Codex"',
       'author: "The House Archive"',
       'lang: en',
       '---', '',
       "*Entries marked [real] are attested history. The rest is what grew in its shadow.*", ""]
for path in sorted(glob.glob("data/codex/*.md")):
    text = pathlib.Path(path).read_text(encoding="utf-8")
    meta, body = {}, text
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if m:
        for line in m.group(1).splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                meta[k.strip()] = v.strip()
        body = m.group(2)
    title = meta.get("title", pathlib.Path(path).stem)
    era = meta.get("era", "")
    real = meta.get("real", "false").lower() == "true"
    out.append(f"# {title}")  # H1: each entry is a chapter with a TOC listing
    tagline = " · ".join(x for x in [era, "[real]" if real else ""] if x)
    if tagline:
        out.append(f"*{tagline}*")
    out.append("")
    out.append(body.strip())
    out.append("")
pathlib.Path("build/long-bronze-codex.md").write_text("\n".join(out), encoding="utf-8")
print("build/long-bronze-codex.md")
PYEOF

if command -v pandoc > /dev/null 2>&1; then
  COVER_ARGS=()
  if [ -f assets/codex/cover.jpg ]; then
    COVER_ARGS=(--epub-cover-image=assets/codex/cover.jpg)
  fi
  pandoc build/long-bronze-codex.md --toc --toc-depth=1 \
    "${COVER_ARGS[@]}" \
    -o build/long-bronze-codex.epub
  echo "build/long-bronze-codex.epub"
else
  echo "(pandoc not found — skipped EPUB. 'apt install pandoc' or 'brew install pandoc' to enable.)"
fi
