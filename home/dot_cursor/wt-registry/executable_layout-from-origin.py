#!/usr/bin/env python3
"""Derive wt-registry paths from a git remote URL. ponytail: stdlib only."""
from __future__ import annotations

import json
import os
import re
import sys
from urllib.parse import urlparse


def parse_origin(url: str) -> tuple[str, list[str]]:
    url = url.strip().rstrip("/")
    if url.endswith(".git"):
        url = url[:-4]
    m = re.match(r"^git@([^:]+):(.+)$", url)
    if m:
        return m.group(1), [p for p in m.group(2).split("/") if p]
    parsed = urlparse(url)
    if parsed.scheme in ("http", "https", "ssh") and parsed.netloc:
        host = parsed.netloc
        path = parsed.path.lstrip("/")
        return host, [p for p in path.split("/") if p]
    raise ValueError(f"unrecognized origin: {url!r}")


def origin_to_repo_id(host: str, path_parts: list[str]) -> str:
    slug = f"{host}-{'-'.join(path_parts)}"
    return re.sub(r"[^a-z0-9-]", "", slug.lower())


def layout_from_origin(url: str, home: str | None = None) -> dict:
    host, parts = parse_origin(url)
    if len(parts) < 1:
        raise ValueError("origin path is empty")
    org, repo = parts[0], parts[-1]
    gitlab_path = "/".join(parts)
    h = home or os.path.expanduser("~")
    path_under_src = os.path.join(*parts)
    return {
        "origin": url,
        "host": host,
        "gitlab_path": gitlab_path,
        "org": org,
        "repo": repo,
        "repo_id": origin_to_repo_id(host, parts),
        "home": os.path.join(h, "src", path_under_src),
        "wt_group": os.path.join(h, "wt", path_under_src),
        "src_repo_basename": repo,
    }


def _self_check() -> None:
    u = "git@github.com:acme/team/widget.git"
    lay = layout_from_origin(u)
    assert lay["org"] == "acme"
    assert lay["repo"] == "widget"
    assert lay["gitlab_path"] == "acme/team/widget"
    assert lay["home"].endswith(os.path.join("src", "acme", "team", "widget"))
    u2 = "git@github.com:acme/widget.git"
    lay2 = layout_from_origin(u2)
    assert lay2["gitlab_path"] == "acme/widget"


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: layout-from-origin.py <origin-url> [origin-url ...]", file=sys.stderr)
        return 2
    if sys.argv[1] == "--self-check":
        _self_check()
        print("ok")
        return 0
    out = [layout_from_origin(u) for u in sys.argv[1:]]
    print(json.dumps(out if len(out) > 1 else out[0], indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
