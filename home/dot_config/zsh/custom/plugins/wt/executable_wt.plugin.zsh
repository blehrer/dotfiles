#!/usr/bin/env zsh

_wt_mv() {
  local wt_root="$HOME/src/worktrees"

  print "Select the worktree group (directory of worktrees) to relocate."
  local wt_dir
  wt_dir=$(find "$wt_root" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort \
    | fzf --header "Select worktree group to move" --prompt "Filter: ")
  [[ -z "$wt_dir" ]] && return 0

  print ""
  print "Enter the destination. Tab-completion is available."
  print "  mv semantics: existing dir → move inside it; new path → rename."
  print "Current: $wt_dir"
  local dest="${wt_root}/"
  vared -p "Move to: " dest
  dest="${dest%/}"
  [[ -z "$dest" ]] && { print "No destination given." >&2; return 1; }

  local new_wt_dir
  [[ -d "$dest" ]] && new_wt_dir="${dest}/$(basename "$wt_dir")" || new_wt_dir="$dest"

  while [[ -e "$new_wt_dir" ]]; do
    print "'$new_wt_dir' already exists. Choose a different destination."
    dest="${wt_root}/"
    vared -p "Move to: " dest
    dest="${dest%/}"
    [[ -z "$dest" ]] && return 1
    [[ -d "$dest" ]] && new_wt_dir="${dest}/$(basename "$wt_dir")" || new_wt_dir="$dest"
  done

  mkdir -p "$new_wt_dir"

  local failed=0
  for wt_path in "$wt_dir"/*(N/); do
    local wt_name="${wt_path:t}"
    local new_wt_path="$new_wt_dir/$wt_name"
    local git_file="$wt_path/.git"

    if [[ ! -f "$git_file" ]]; then
      print "Warning: no .git file in $wt_path, skipping." >&2
      (( failed++ ))
      continue
    fi

    local gitdir_raw
    gitdir_raw=$(sed 's/^gitdir: //' "$git_file")
    local gitdir_abs
    if [[ "$gitdir_raw" = /* ]]; then
      gitdir_abs="$gitdir_raw"
    else
      gitdir_abs="$(cd "$wt_path" && cd "$gitdir_raw" && pwd)"
    fi
    # gitdir_abs = /repo/.git/worktrees/<name>  →  repo .git = grandparent
    local repo_git_dir="${gitdir_abs:h:h}"

    git --git-dir="$repo_git_dir" worktree move "$wt_path" "$new_wt_path" \
      && print "  moved: $wt_path → $new_wt_path" \
      || { print "  failed: $wt_path" >&2; (( failed++ )); }
  done

  if (( failed == 0 )); then
    rm -rf "$wt_dir"
    print "Removed: $wt_dir"
  else
    print "Warning: some moves failed; '$wt_dir' was not removed." >&2
    return 1
  fi
}

_wt_init() {
  local src_root="$HOME/src/gitlab.disney.com"
  local wt_root="$HOME/src/worktrees"
  local branch_name=""
  local ref_name=""
  local -a repos=()
  local -a repo_paths=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --src-root)      src_root="$2";               shift 2 ;;
      --worktree-root) wt_root="$2";                shift 2 ;;
      --branch)        branch_name="$2";            shift 2 ;;
      --ref)           ref_name="$2";               shift 2 ;;
      --repos)         repos=("${(s:,:)2}");        shift 2 ;;
      --help|-h)
        print "Usage: wt init [--src-root DIR] [--worktree-root DIR] [--branch NAME] [--ref REF] [--repos NAME,...]"
        return 0 ;;
      *)
        print "Unknown argument: $1" >&2
        return 1 ;;
    esac
  done

  # Step 1: resolve repo paths
  print "Select one or more source repos to create worktrees from (Tab to multi-select)."
  if [[ ${#repos[@]} -eq 0 ]]; then
    local selection
    selection=$(find "$src_root" -maxdepth 5 -type d \( -name ".git" -o -name "*.git" \) 2>/dev/null \
      | sed 's|/\.git$||' \
      | sort -u \
      | fzf --multi --header "Source Repos" --prompt "Filter: ")
    [[ -z "$selection" ]] && { print "No repos selected."; return 0; }
    repo_paths=("${(f)selection}")
  else
    local all_repos
    all_repos=$(find "$src_root" -maxdepth 5 -type d \( -name ".git" -o -name "*.git" \) 2>/dev/null | sed 's|/\.git$||')
    for r in "${repos[@]}"; do
      if [[ -d "$r" ]]; then
        repo_paths+=("$r")
      else
        local match
        match=$(print "$all_repos" | grep -m1 "/$r$" || true)
        if [[ -z "$match" ]]; then
          print "Repo not found: $r" >&2
          return 1
        fi
        repo_paths+=("$match")
      fi
    done
  fi

  # Step 2: prompt for worktree root dir
  print ""
  print "Enter the directory that will group all these worktrees. Tab-completion is available."
  local wt_dir="${wt_root}/"
  vared -p "Worktree root: " wt_dir
  wt_dir="${wt_dir%/}"
  [[ -z "$wt_dir" ]] && { print "No directory given." >&2; return 1; }

  # Step 3: existing dir guard
  if [[ -d "$wt_dir" ]]; then
    local confirm
    read -r "confirm?Directory '$wt_dir' exists. Add worktrees here? [Y/n] "
    [[ "${confirm:l}" == "n" ]] && return 0
  fi
  mkdir -p "$wt_dir"

  # Step 4: branch/ref prompt (once for all repos)
  if [[ -z "$branch_name" ]]; then
    read -r "branch_name?New branch name (empty = detached worktree): "
    if [[ -n "$branch_name" && -z "$ref_name" ]]; then
      ref_name="HEAD"
      vared -p "Starting ref [$ref_name]: " ref_name
      [[ -z "$ref_name" ]] && ref_name="HEAD"
    fi
  elif [[ -n "$branch_name" && -z "$ref_name" ]]; then
    ref_name="HEAD"
  fi

  # Step 5: create each worktree
  local failed=0
  for repo in "${repo_paths[@]}"; do
    local wt_name
    wt_name=$(basename "$repo")
    vared -p "Worktree name for '$(basename "$repo")': " wt_name

    local wt_path="$wt_dir/$wt_name"
    while [[ -e "$wt_path" ]]; do
      print "Path '$wt_path' already exists. Choose a different name."
      vared -p "Worktree name: " wt_name
      wt_path="$wt_dir/$wt_name"
    done

    if [[ -n "$branch_name" ]]; then
      git -C "$repo" worktree add -b "$branch_name" "$wt_path" "$ref_name" || { failed=1; continue; }
    else
      git -C "$repo" worktree add "$wt_path" || { failed=1; continue; }
    fi
    print "  created: $wt_path"
  done

  [[ $failed -ne 0 ]] && print "Warning: one or more worktrees failed to create." >&2

  # Step 6: cd into worktree dir
  cd "$wt_dir"
  print "Now in: $wt_dir"
}

wt() {
  case "$1" in
    init)      shift; _wt_init "$@"; return ;;
    mv|move)   shift; _wt_mv   "$@"; return ;;
    -h|--help)
      print "Usage: wt [init|mv|move] [-h|--help]"
      print ""
      print "  (bare)     prompt for a worktree group path and cd into it"
      print "  init       create a new worktree group from one or more repos"
      print "  mv|move    move a worktree group to a new location"
      return 0 ;;
  esac

  local wt_root="${HOME}/src/worktrees"
  print "Enter the worktree group to jump into. Tab-completion is available."
  local wt_dir="${wt_root}/"
  vared -p "Worktree root: " wt_dir
  wt_dir="${wt_dir%/}"
  [[ -z "$wt_dir" ]] && { print "No directory given." >&2; return 1; }
  cd "$wt_dir"
}

alias mkwt='wt init'
