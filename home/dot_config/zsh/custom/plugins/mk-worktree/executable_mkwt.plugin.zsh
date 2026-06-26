#!/usr/bin/env zsh

mkwt() {
  local src_root="$HOME/src/gitlab.disney.com"
  local wt_root="$HOME/src/worktrees"
  local branch_name=""
  local ref_name=""
  local -a repos=()
  local -a repo_paths=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --src-root)     src_root="$2";                       shift 2 ;;
      --worktree-root) wt_root="$2";                       shift 2 ;;
      --branch)       branch_name="$2";                    shift 2 ;;
      --ref)          ref_name="$2";                       shift 2 ;;
      --repos)        repos=("${(s:,:)2}");                shift 2 ;;
      --help|-h)
        print "Usage: mkwt [--src-root DIR] [--worktree-root DIR] [--branch NAME] [--ref REF] [--repos NAME,...]"
        return 0 ;;
      *)
        print "Unknown argument: $1" >&2
        return 1 ;;
    esac
  done

  # Step 1: resolve repo paths
  if [[ ${#repos[@]} -eq 0 ]]; then
    local selection
    selection=$(find "$src_root" -maxdepth 5 -name ".git" -type d 2>/dev/null \
      | sed 's|/.git$||' \
      | sort \
      | fzf --multi --header "Source Repos" --prompt "Filter: ")
    [[ -z "$selection" ]] && { print "No repos selected."; return 0; }
    repo_paths=("${(f)selection}")
  else
    # resolve short names or full paths
    local all_repos
    all_repos=$(find "$src_root" -maxdepth 5 -name ".git" -type d 2>/dev/null | sed 's|/.git$||')
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
