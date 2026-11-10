#!/usr/bin/env python3
"""Approximate Cursor project dir slug from absolute path (alphanumeric + hyphens)."""
import hashlib
import re
import sys


def slugify_path(path: str) -> str:
    path = path.rstrip("/")
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", path).strip("-").lower()
    if len(slug) > 180:
        digest = hashlib.sha256(path.encode()).hexdigest()[:12]
        slug = f"{slug[:160]}-{digest}"
    return slug


if __name__ == "__main__":
    print(slugify_path(sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read().strip()))
