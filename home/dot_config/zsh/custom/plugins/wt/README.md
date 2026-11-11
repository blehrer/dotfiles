Chezmoi source file: `executable_wt.plugin.zsh` → `~/.config/zsh/custom/plugins/wt/wt.plugin.zsh`.

Do **not** add a second `wt.plugin.zsh` in this directory (chezmoi will report inconsistent state).

After copying your plugin:

```bash
~/.cursor/wt-registry/apply-wt-defaults.sh "$PWD/executable_wt.plugin.zsh"
```

Tests source `executable_wt.plugin.zsh` directly.
