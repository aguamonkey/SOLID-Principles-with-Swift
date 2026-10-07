#!/usr/bin/env python3
"""Check repository Markdown inline links, HTML images/links, and heading anchors.

External URLs are intentionally not fetched. Fenced examples are ignored.
Use inline links (rather than reference definitions) for checked navigation.
"""
from html import unescape
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
LINK = re.compile(r'\]\((<[^>]+>|(?:[^()\s]|\([^()]*\))+)(?:\s+"[^"]*")?\)|\b(?:src|href)=["\']([^"\']+)["\']')


def prose_lines(text):
    fence = None
    for number, line in enumerate(text.splitlines(), 1):
        marker = re.match(r"^\s{0,3}(`{3,}|~{3,})", line)
        if marker:
            token = marker.group(1)
            if fence is None:
                fence = token
            elif token[0] == fence[0] and len(token) >= len(fence):
                fence = None
            continue
        if fence is None:
            yield number, line


def anchors(text):
    found = set()
    counts = {}
    for _, line in prose_lines(text):
        heading = re.match(r"^#{1,6}\s+(.+?)\s*#*\s*$", line)
        if not heading:
            continue
        title = re.sub(r"<[^>]+>", "", unescape(heading.group(1))).lower()
        slug = re.sub(r"[^\w\- ]", "", title).replace(" ", "-")
        count = counts.get(slug, 0)
        counts[slug] = count + 1
        found.add(f"{slug}-{count}" if count else slug)
    return found


def check_document(source, root):
    errors = []
    for number, line in prose_lines(source.read_text()):
        for match in LINK.finditer(line):
            raw = unescape((match.group(1) or match.group(2)).strip("<>"))
            url = urlsplit(raw)
            if url.scheme or url.netloc:
                continue
            target = (source.parent / unquote(url.path)).resolve() if url.path else source
            label = f"{source.relative_to(root)}:{number}: {raw}"
            if not target.is_relative_to(root):
                errors.append(f"{label} leaves the repository")
            elif not target.exists():
                errors.append(f"{label} does not exist")
            elif url.fragment and target.suffix.lower() == ".md" and unquote(url.fragment) not in anchors(target.read_text()):
                errors.append(f"{label} has no matching heading")
    return errors


def main():
    paths = subprocess.check_output(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], cwd=ROOT).decode().split("\0")
    documents = sorted({ROOT / p for p in paths if p.lower().endswith(".md")})
    errors = [error for document in documents for error in check_document(document, ROOT)]
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"Documentation links and images passed ({len(documents)} Markdown files).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
