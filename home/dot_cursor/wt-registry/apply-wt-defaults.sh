#!/usr/bin/env bash
# Patch wt.plugin.zsh: default bsl_repos=~/src, bsl_wts=~/wt (no exports required).
set -euo pipefail

PLUGIN="${1:-$HOME/.config/zsh/custom/plugins/wt/wt.plugin.zsh}"

[[ -f "$PLUGIN" ]] || {
  echo "Plugin not found: $PLUGIN" >&2
  exit 1
}

if grep -q 'bsl_wts:=\$HOME/wt' "$PLUGIN" 2>/dev/null; then
  echo "Defaults already present in $PLUGIN"
  exit 0
fi

tmp="$(mktemp)"
awk '
  NR == 1 { print; print ""; print ": ${bsl_repos:=$HOME/src}"; print ": ${bsl_wts:=$HOME/wt}"; next }
  { gsub(/\$\{bsl_wts:-\$HOME\/src\/worktrees\}/, "$bsl_wts");
    gsub(/local wt_root="\$HOME\/src\/worktrees"/, "local wt_root=\"$bsl_wts\"");
    print }
' "$PLUGIN" >"$tmp"
mv "$tmp" "$PLUGIN"
chmod +x "$PLUGIN" 2>/dev/null || true
echo "Patched: $PLUGIN"
