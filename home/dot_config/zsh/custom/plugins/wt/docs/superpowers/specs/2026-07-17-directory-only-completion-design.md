# Directory-only path completion

## Goal

All interactive path prompts in `wt` must offer directories only. Regular files must not appear as completion candidates.

## Design

Add one helper that invokes `vared` with directory-only completion scoped to that prompt. Use the helper for the bare `wt` worktree prompt, the `wt init` worktree-root prompt, and both destination prompts in `wt mv`.

Command-line options already use `_directories`, so their behavior does not need to change. Free-form values such as branch names and worktree names keep their existing completion behavior.

The helper must restore any completion state it changes before returning, including when `vared` fails, so it does not affect completion elsewhere in the shell.

## Check

Extend the completion test with a temporary directory containing one child directory and one regular file. Exercise the prompt's completion function and verify that the directory is offered and the file is omitted.
