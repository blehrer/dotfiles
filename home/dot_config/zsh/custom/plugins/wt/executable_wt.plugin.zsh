#!/usr/bin/env zsh

_wt_has_worktree_children() {
  local wt_root="$1"
  local wt_path

  for wt_path in "$wt_root"/*(N/); do
    [[ -f "$wt_path/.git" ]] && return 0
  done

  return 1
}

_wt_current_worktree_root() {
  local dir="${PWD:A}"

  if _wt_has_worktree_children "$dir"; then
    print -r -- "$dir"
    return 0
  fi

  local probe="$dir"
  while [[ "$probe" != "/" ]]; do
    if [[ -f "$probe/.git" ]] && _wt_has_worktree_children "${probe:h}"; then
      print -r -- "${probe:h}"
      return 0
    fi
    probe="${probe:h}"
  done

  return 1
}

_wt_find_worktree_roots_below() {
  local search_dir="${1:A}"
  local -a candidates=()
  local candidate

  candidates=(
    "$search_dir"
    "$search_dir"/*(N/)
    "$search_dir"/*/*(N/)
  )

  for candidate in "${candidates[@]}"; do
    _wt_has_worktree_children "$candidate" && print -r -- "${candidate:A}"
  done | sort -u
}

_wt_status_roots_for_cwd() {
  local current_root
  if current_root=$(_wt_current_worktree_root); then
    print -r -- "$current_root"
    return 0
  fi

  local wt_base="${bsl_wts:-$HOME/src/worktrees}"
  local dir="${PWD:A}"
  local base="${wt_base:A}"

  [[ -d "$base" ]] || { print "Worktree base not found: $base" >&2; return 1; }
  if [[ "$dir" == "$base" || "$dir" == "$base"/* ]]; then
    _wt_find_worktree_roots_below "$dir"
    return 0
  fi

  print "Not inside a worktree root or worktree base: $dir" >&2
  return 1
}

_wt_status_root_label() {
  local wt_root="${1:A}"
  local wt_base="${bsl_wts:-$HOME/src/worktrees}"
  local base="${wt_base:A}"

  if [[ -d "$base" && "$wt_root" == "$base"/* ]]; then
    print -r -- "${wt_root#$base/}"
  elif [[ "$wt_root" == "$HOME"/* ]]; then
    print -r -- "~/${wt_root#$HOME/}"
  else
    print -r -- "$wt_root"
  fi
}

_wt_print_status_for_root() {
  local wt_root="${1:A}"
  local -a worktrees=()
  local wt_path
  local prompt_output
  local prompt_line

  [[ -d "$wt_root" ]] || { print "Worktree root not found: $wt_root" >&2; return 1; }
  for wt_path in "$wt_root"/*(N/); do
    [[ -f "$wt_path/.git" ]] && worktrees+=("${wt_path:A}")
  done
  [[ ${#worktrees[@]} -gt 0 ]] || { print "No worktrees found in: $wt_root"; return 0; }

  print -r -- "$(_wt_status_root_label "$wt_root")"
  local failed=0
  for wt_path in "${worktrees[@]}"; do
    # SECURITY-REVIEW: wt_path is an existing child directory and is quoted before cd/starship invocation.
    if prompt_output=$(cd "$wt_path" && starship prompt); then
      prompt_output="${prompt_output//\%\{/}"
      prompt_output="${prompt_output//\%\}/}"
      for prompt_line in "${(@f)prompt_output}"; do
        [[ -n "$prompt_line" ]] && print -r -- "  $prompt_line"
      done
    else
      failed=1
    fi
  done
  return $failed
}

_wt_fzf_pick_lines() {
  local header="$1" selection
  shift
  local -a choices=("$@")

  (( $+commands[fzf] )) || return 2
  [[ ${#choices[@]} -gt 0 ]] || return 1

  selection=$(print -rl -- "${choices[@]}" | sort | command fzf \
    --height '~12' \
    --layout reverse \
    --border \
    --info inline \
    --header "$header" \
    --prompt "Filter: ") || return 1
  [[ -n "$selection" ]] || return 1
  REPLY="$selection"
  return 0
}

_wt_nested_worktree_group_roots() {
  local wt_base="${1:A}"
  local parent candidate
  local -a roots=()

  [[ -d "$wt_base" ]] || return 1

  setopt localoptions extendedglob nullglob
  for parent in "$wt_base"/*(N/); do
    for candidate in "$parent"/*(N/); do
      _wt_has_worktree_children "$candidate" && roots+=("${candidate:A}")
    done
  done

  reply=("${roots[@]}")
  return 0
}

_wt_pick_worktree_root() {
  local header="${1:-Select worktree group}"
  local wt_base="${bsl_wts:-$HOME/src/worktrees}"
  local -a groups labels
  local root

  [[ -d "$wt_base" ]] || { print "Worktree base not found: $wt_base" >&2; return 1; }
  wt_base="${wt_base:A}"

  _wt_nested_worktree_group_roots "$wt_base" || return 1
  groups=("${reply[@]}")
  [[ ${#groups[@]} -gt 0 ]] || { print "No worktree groups found in: $wt_base" >&2; return 1; }

  for root in "${groups[@]}"; do
    labels+=("${root#${wt_base}/}")
  done

  if _wt_fzf_pick_lines "$header" "${labels[@]}"; then
    local i
    for i in {1..${#groups[@]}}; do
      if [[ "${labels[i]}" == "$REPLY" ]]; then
        print -r -- "${groups[i]}"
        return 0
      fi
    done
  fi
  return 1
}

_wt_repo_git_dir_for_worktree() {
  local wt_path="$1"
  local git_file="$wt_path/.git"
  local gitdir_line gitdir_raw gitdir_abs

  [[ -f "$git_file" ]] || return 1
  IFS= read -r gitdir_line < "$git_file" || return 1
  [[ "$gitdir_line" == gitdir:\ * ]] || return 1

  gitdir_raw="${gitdir_line#gitdir: }"
  if [[ "$gitdir_raw" = /* ]]; then
    gitdir_abs="$gitdir_raw"
  else
    gitdir_abs="$(cd "$wt_path" && cd "$gitdir_raw" && pwd -P)" || return 1
  fi

  print -r -- "${gitdir_abs:h:h}"
}

_wt_progress_line() {
  local done="$1"
  local total="$2"
  local label="$3"
  local spinner="$4"
  local width=24
  local filled=$(( done * width / total ))
  local empty=$(( width - filled ))
  local bar=""
  local i

  i=0
  while (( i < filled )); do
    bar+="#"
    (( i++ ))
  done
  i=0
  while (( i < empty )); do
    bar+="-"
    (( i++ ))
  done

  print -rn -- "\rRemoving [$bar] $done/$total $spinner $label"
}

_wt_run_with_progress() {
  local done="$1"
  local total="$2"
  local label="$3"
  shift 3

  local tmp_output
  tmp_output=$(mktemp "${TMPDIR:-/tmp}/wt-edit.XXXXXX") || return 1

  "$@" > "$tmp_output" 2>&1 &
  local pid=$!
  local -a spinners=("|" "/" "-" "\\")
  local spinner_index=1

  while kill -0 "$pid" 2>/dev/null; do
    _wt_progress_line "$done" "$total" "$label" "$spinners[$spinner_index]"
    spinner_index=$(( spinner_index % ${#spinners[@]} + 1 ))
    sleep 0.2
  done

  wait "$pid"
  local rc=$?

  if (( rc == 0 )); then
    _wt_progress_line "$done" "$total" "$label" "done"
  else
    _wt_progress_line "$done" "$total" "$label" "failed"
  fi
  print ""

  if [[ -s "$tmp_output" ]]; then
    print -u2 -r -- "$(< "$tmp_output")"
  fi
  rm -f -- "$tmp_output"

  return $rc
}

# ponytail: scan one directory level with -d; no compsys or extendedglob
_wt_directory_match_prefix() {
  local dir="$1" prefix="$2" entry base
  local -a results

  dir="${~dir}"
  [[ -d "$dir" ]] || return 1
  [[ "$dir" == */ ]] || dir="${dir}/"

  setopt localoptions nullglob
  for entry in "$dir"*; do
    [[ -d "$entry" ]] || continue
    base="${entry:t}"
    [[ -z "$prefix" || "$base" == "$prefix"* ]] && results+=("$entry")
  done

  reply=("${results[@]}")
}

_wt_directory_complete_word() {
  local dir prefix common m len
  local -a matches names

  if [[ -z "$LBUFFER" ]]; then
    dir="${PWD}/"
    prefix=""
  elif [[ "$LBUFFER" == */ ]]; then
    dir="$LBUFFER"
    prefix=""
  elif [[ "$LBUFFER" == */* ]]; then
    dir="${LBUFFER%/*}/"
    prefix="${LBUFFER##*/}"
  else
    dir="${PWD}/"
    prefix="$LBUFFER"
  fi

  _wt_directory_match_prefix "$dir" "$prefix" || { zle beep; return 1 }
  matches=("${reply[@]}")
  if (( ${#matches[@]} == 0 )); then
    zle beep
    return 1
  fi

  if (( ${#matches[@]} == 1 )); then
    LBUFFER="${matches[1]}/"
  else
    common="${matches[1]}"
    for m in "${matches[2,-1]}"; do
      len=${#common}
      while (( len > 0 )) && [[ "${common[1,$len]}" != "${m[1,$len]}" ]]; do
        (( len-- ))
      done
      common="${common[1,$len]}"
    done
    if [[ -n "$common" && "$common" != "$LBUFFER" ]]; then
      LBUFFER="$common"
    else
      names=("${(@)matches[@]:t}")
      zle -M "${(j:,:)names}"
    fi
  fi
  CURSOR=$#LBUFFER
}

_wt_vared_directory() {
  local prompt="$1"
  local parameter="$2"
  local keymap="wt-directory-${$}-${RANDOM}"
  local widget="_wt-directory-complete-${$}-${RANDOM}"
  local rc

  zle -N "$widget" _wt_directory_complete_word
  bindkey -N "$keymap" main
  bindkey -M "$keymap" '^I' "$widget"

  if vared -M "$keymap" -p "$prompt" "$parameter"; then
    rc=0
  else
    rc=$?
  fi

  bindkey -D "$keymap"
  zle -D "$widget"
  return $rc
}

_wt_status() {
  local wt_root=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --worktree-root) wt_root="$2"; shift 2 ;;
      --help|-h)
        print "Usage: wt status [--worktree-root DIR]"
        print ""
        print "Show Starship prompts for worktrees in a worktree root."
        return 0 ;;
      *)
        print "Unknown argument: $1" >&2
        return 1 ;;
    esac
  done

  (( $+commands[starship] )) || { print "starship not found in PATH" >&2; return 1; }

  local roots_output
  if [[ -n "$wt_root" ]]; then
    roots_output="${wt_root:A}"
  else
    roots_output=$(_wt_status_roots_for_cwd) || return 1
  fi

  local -a roots=("${(@f)roots_output}")
  [[ ${#roots[@]} -gt 0 ]] || { print "No worktree roots found."; return 0; }

  local failed=0
  local root
  local first=1
  for root in "${roots[@]}"; do
    (( first )) || print "\n"
    _wt_print_status_for_root "$root" || failed=1
    first=0
  done
  return $failed
}

_wt_doctor_worktrees_for_root() {
  local wt_root="${1:A}"
  local wt_path

  [[ -d "$wt_root" ]] || return 1
  for wt_path in "$wt_root"/*(N/); do
    print -r -- "${wt_path:A}"
  done
}

_wt_doctor_worktree_label() {
  local wt_path="${1:A}"
  local wt_root="${2:A}"
  local root_label="${wt_root:t}"

  if [[ -n "$root_label" ]]; then
    print -r -- "$root_label/${wt_path:t}"
  else
    print -r -- "${wt_path:t}"
  fi
}

_wt_doctor_read_gitdir() {
  local wt_path="${1:A}"
  local git_file="$wt_path/.git"
  local gitdir_line gitdir_raw repo_path

  [[ -f "$git_file" && ! -d "$git_file" ]] || return 1
  IFS= read -r gitdir_line < "$git_file" || return 1
  [[ "$gitdir_line" == gitdir:\ * ]] || return 1

  gitdir_raw="${gitdir_line#gitdir: }"
  gitdir_raw="${gitdir_raw#"${gitdir_raw%%[![:space:]]*}"}"
  gitdir_raw="${gitdir_raw%"${gitdir_raw##*[![:space:]]}"}"
  [[ -n "$gitdir_raw" ]] || return 1

  if [[ "$gitdir_raw" = ~* ]]; then
    repo_path="${~gitdir_raw:A}"
  elif [[ "$gitdir_raw" = /* ]]; then
    repo_path="${gitdir_raw:A}"
  else
    repo_path="$(cd "$wt_path" && cd "$gitdir_raw" && pwd -P)" || return 1
  fi

  [[ -d "$repo_path" ]] || return 1

  print -r -- "$repo_path"
}

_wt_doctor_repo_knows_worktree() {
  local repo_path="$1"
  local wt_path="${2:A}"
  local line

  while IFS= read -r line; do
    [[ "$line" == worktree\ * ]] || continue
    [[ "${line#worktree }" == "$wt_path" ]] && return 0
  done < <(git -C "$repo_path" worktree list --porcelain 2>/dev/null)

  return 1
}

_wt_doctor_report_error() {
  local code="$1" wt_path="$2" detail="$3" label="$4"

  print -u2 -r -- "error [$code] $label: $detail"
  _wt_doctor_errors+=("$code|$wt_path|$detail|$label")
}

_wt_doctor_print_status() {
  local label="$1"
  local state="$2"

  case "$state" in
    ok)
      print -P -r -- "  $label  %F{green}OK%f"
      ;;
    orphan)
      print -P -r -- "  $label  %F{red}ORPHAN%f"
      ;;
    *)
      print -P -r -- "  $label  %F{red}NOT OK%f"
      ;;
  esac
}

_wt_doctor_check_worktree() {
  local wt_path="${1:A}"
  local wt_root="${2:A}"
  local label="$(_wt_doctor_worktree_label "$wt_path" "$wt_root")"
  local git_file="$wt_path/.git"
  local repo_path git_raw gitdir_raw

  if [[ -d "$git_file" ]]; then
    _wt_doctor_report_error gitdir_invalid "$wt_path" \
      ".git is a directory, expected a file with 'gitdir: /path/to/repo'" "$label"
    reply=(not_ok)
    return 1
  fi
  if [[ ! -f "$git_file" ]]; then
    _wt_doctor_report_error missing_git "$wt_path" "no .git file" "$label"
    reply=(not_ok)
    return 1
  fi

  git_raw=$(< "$git_file")
  git_raw="${git_raw#"${git_raw%%[![:space:]]*}"}"
  git_raw="${git_raw%"${git_raw##*[![:space:]]}"}"

  if [[ "$git_raw" == gitdir:\ * ]]; then
    gitdir_raw="${git_raw#gitdir: }"
  else
    _wt_doctor_report_error gitdir_invalid "$wt_path" \
      ".git missing gitdir line (expected 'gitdir: /path/to/repo')" "$label"
    reply=(not_ok)
    return 1
  fi

  if ! repo_path=$(_wt_doctor_read_gitdir "$wt_path"); then
    _wt_doctor_report_error gitdir_invalid "$wt_path" \
      ".git gitdir points to missing or empty path: ${gitdir_raw:-<empty>}" "$label"
    reply=(not_ok)
    return 1
  fi

  if ! _wt_doctor_repo_knows_worktree "$repo_path" "$wt_path"; then
    _wt_doctor_report_error gitdir_worktree_unknown "$wt_path" \
      "main repo does not list this worktree ($repo_path)" "$label"
    reply=(orphan)
    return 1
  fi

  reply=(ok)
  return 0
}

_wt_doctor_prompt_missing_git() {
  local wt_path="$1"
  local label="$2"

  cat <<EOF
You are helping repair a git worktree managed by the wt zsh plugin.

Worktree path: $wt_path
Label: $label
Problem: missing .git file

The worktree directory should contain a .git file with one line like:
gitdir: /absolute/path/to/main/repo

Suggest concrete shell commands to create the correct .git file and verify the setup. Prefer read-only checks first, then minimal writes.
EOF
}

_wt_doctor_prompt_gitdir_invalid() {
  local wt_path="$1"
  local detail="$2"
  local label="$3"

  cat <<EOF
You are helping repair a git worktree managed by the wt zsh plugin.

Worktree path: $wt_path
Label: $label
Problem: invalid .git gitdir
Details: $detail

The .git file should contain one line like:
gitdir: /absolute/path/to/main/repo

Suggest concrete shell commands to diagnose and fix the .git file. Prefer read-only checks first, then minimal writes.
EOF
}

_wt_doctor_prompt_gitdir_worktree_unknown() {
  local wt_path="$1"
  local detail="$2"
  local label="$3"

  cat <<EOF
You are helping repair a git worktree managed by the wt zsh plugin.

Worktree path: $wt_path
Label: $label
Problem: main repository does not register this worktree
Details: $detail

The .git gitdir path exists but \`git -C <repo> worktree list\` does not include this worktree directory.

Suggest concrete shell commands to re-register or repair the worktree link without losing uncommitted work when possible.
EOF
}

_wt_doctor_prompt_for() {
  local code="$1" wt_path="$2" detail="$3" label="$4"

  case "$code" in
    missing_git)
      _wt_doctor_prompt_missing_git "$wt_path" "$label"
      ;;
    gitdir_invalid)
      _wt_doctor_prompt_gitdir_invalid "$wt_path" "$detail" "$label"
      ;;
    gitdir_worktree_unknown)
      _wt_doctor_prompt_gitdir_worktree_unknown "$wt_path" "$detail" "$label"
      ;;
    *)
      print -r -- "Unknown wt doctor error code: $code (worktree: $wt_path; detail: $detail)"
      ;;
  esac
}

_wt_doctor_apfel_suggest() {
  local prompt="$1"

  (( $+commands[apfel] )) || { print "apfel not found in PATH" >&2; return 1; }
  # SECURITY-REVIEW: prompt is built from local paths and error codes, not raw user input.
  apfel --stream "$prompt"
}

_wt_doctor_suggest_fixes() {
  local entry code wt_path detail label prompt failed=0

  [[ ${#_wt_doctor_errors[@]} -gt 0 ]] || return 0

  for entry in "${_wt_doctor_errors[@]}"; do
    local -a parts=("${(@s:|:)entry}")
    code="$parts[1]"
    wt_path="$parts[2]"
    detail="$parts[3]"
    label="$parts[4]"

    prompt=$(_wt_doctor_prompt_for "$code" "$wt_path" "$detail" "$label")
    print -r -- ""
    print -r -- "suggest [$code] $label"
    if ! _wt_doctor_apfel_suggest "$prompt"; then
      failed=1
    fi
  done

  return $failed
}

_wt_doctor_check_root() {
  local wt_root="${1:A}"
  local -a worktrees=()
  local wt_path failed=0

  [[ -d "$wt_root" ]] || { print "Worktree root not found: $wt_root" >&2; return 1; }

  worktrees=("${(@f)$(_wt_doctor_worktrees_for_root "$wt_root")}")
  [[ ${#worktrees[@]} -gt 0 ]] || { print "No worktrees found in: $(_wt_status_root_label "$wt_root")"; return 0; }

  print -r -- "$(_wt_status_root_label "$wt_root")"
  for wt_path in "${worktrees[@]}"; do
    local label="$(_wt_doctor_worktree_label "$wt_path" "$wt_root")"
    _wt_doctor_check_worktree "$wt_path" "$wt_root"
    _wt_doctor_print_status "$label" "${reply[1]}"
    (( ${#reply[@]} > 0 && reply[1] != ok )) && failed=1
  done

  return $failed
}

_wt_doctor() {
  local wt_root=""
  local suggest=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --worktree-root) wt_root="$2"; shift 2 ;;
      --suggest) suggest=1; shift ;;
      --help|-h)
        print "Usage: wt doctor [--worktree-root DIR] [--suggest]"
        print ""
        print "Check worktrees for .git gitdir health and optionally ask apfel for fix suggestions."
        return 0 ;;
      *)
        print "Unknown argument: $1" >&2
        return 1 ;;
    esac
  done

  typeset -ga _wt_doctor_errors=()

  local roots_output
  if [[ -n "$wt_root" ]]; then
    roots_output="${wt_root:A}"
  else
    roots_output=$(_wt_status_roots_for_cwd) || return 1
  fi

  local -a roots=("${(@f)roots_output}")
  [[ ${#roots[@]} -gt 0 ]] || { print "No worktree roots found."; return 0; }

  local failed=0
  local root
  local first=1
  for root in "${roots[@]}"; do
    (( first )) || print ""
    _wt_doctor_check_root "$root" || failed=1
    first=0
  done

  if (( suggest && ${#_wt_doctor_errors[@]} > 0 )); then
    _wt_doctor_suggest_fixes || failed=1
  fi

  (( ${#_wt_doctor_errors[@]} == 0 )) || failed=1
  return $failed
}

_wt_edit() {
  local wt_root=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --worktree-root) wt_root="$2"; shift 2 ;;
      --help|-h)
        print "Usage: wt edit [--worktree-root DIR]"
        print ""
        print "Remove selected worktrees from a worktree group."
        return 0 ;;
      *)
        print "Unknown argument: $1" >&2
        return 1 ;;
    esac
  done

  if [[ -z "$wt_root" ]]; then
    wt_root=$(_wt_current_worktree_root) || wt_root=$(_wt_pick_worktree_root "Select worktree group to edit") || return 0
  fi

  wt_root="${wt_root:A}"
  [[ -d "$wt_root" ]] || { print "Worktree root not found: $wt_root" >&2; return 1; }

  local -a worktrees=()
  local wt_path
  for wt_path in "$wt_root"/*(N/); do
    [[ -f "$wt_path/.git" ]] && worktrees+=("$wt_path")
  done
  [[ ${#worktrees[@]} -gt 0 ]] || { print "No worktrees found in: $wt_root"; return 0; }

  print "Select one or more worktrees to remove (Tab to multi-select)."
  local selection
  selection=$(for wt_path in "${worktrees[@]}"; do print -r -- "$wt_path"; done | sort \
    | fzf --multi --header "Remove Worktrees" --prompt "Filter (Use TAB to select many, submit with ENTER): ")
  [[ -z "$selection" ]] && { print "No worktrees selected."; return 0; }

  local -a selected=("${(f)selection}")
  local failed=0
  local total=${#selected[@]}
  local done=0
  for wt_path in "${selected[@]}"; do
    local wt_abs="${wt_path:A}"
    local root_abs="${wt_root:A}"
    if [[ "$wt_abs" != "$root_abs"/* ]]; then
      print "Warning: selected path is outside worktree root, skipping: $wt_path" >&2
      (( failed++ ))
      continue
    fi

    local repo_git_dir
    repo_git_dir=$(_wt_repo_git_dir_for_worktree "$wt_abs") || {
      print "Warning: could not resolve git root for $wt_abs, skipping." >&2
      (( failed++ ))
      continue
    }

    # SECURITY-REVIEW: paths are user/fzf-selected but constrained to immediate children and quoted before git/rm.
    if _wt_run_with_progress "$done" "$total" "${wt_abs:t}" git --git-dir="$repo_git_dir" worktree remove "$wt_abs"; then
      if [[ -e "$wt_abs" ]]; then
        _wt_run_with_progress "$done" "$total" "${wt_abs:t}" rm -rf -- "$wt_abs" || {
          print "  failed: $wt_abs" >&2
          (( failed++ ))
          continue
        }
      fi
      (( done++ ))
      _wt_progress_line "$done" "$total" "${wt_abs:t}" "done"
      print ""
      print "  removed: $wt_abs"
    else
      print "  failed: $wt_abs" >&2
      (( failed++ ))
    fi
  done

  (( failed == 0 )) || return 1
}

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
  _wt_vared_directory "Move to: " dest
  dest="${dest%/}"
  [[ -z "$dest" ]] && { print "No destination given." >&2; return 1; }

  local new_wt_dir
  [[ -d "$dest" ]] && new_wt_dir="${dest}/$(basename "$wt_dir")" || new_wt_dir="$dest"

  while [[ -e "$new_wt_dir" ]]; do
    print "'$new_wt_dir' already exists. Choose a different destination."
    dest="${wt_root}/"
    _wt_vared_directory "Move to: " dest
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
  local src_root="$bsl_repos"
  local wt_root="$bsl_wts"
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
      | fzf --multi --header "Source Repos" --prompt "Filter (Use TAB to select many, submit with ENTER): ")
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
  _wt_vared_directory "Worktree root: " wt_dir
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

_wt_completion() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  local -a subcommands
  subcommands=(
    "init:Create a new worktree group"
    "edit:Remove selected worktrees"
    "status:Show Starship prompts for worktrees"
    "doctor:Check worktrees and suggest fixes"
    "mv:Move a worktree group"
    "move:Move a worktree group"
    "completion:Print zsh completion script"
    "-h:Show help"
    "--help:Show help"
  )

  _arguments -C \
    "1:subcommand:->subcommand" \
    "*::argument:->argument" && return

  case "$state" in
    subcommand)
      _describe "wt subcommands" subcommands
      ;;
    argument)
      case "$words[2]" in
        init)
          _arguments \
            "--src-root[Source repo root]:directory:_directories" \
            "--worktree-root[Worktree root]:directory:_directories" \
            "--branch[New branch name]:branch name:" \
            "--ref[Starting ref]:ref:" \
            "--repos[Comma-separated repo names]:repo names:" \
            {-h,--help}"[Show help]"
          ;;
        edit)
          _arguments \
            "--worktree-root[Worktree root]:directory:_directories" \
            {-h,--help}"[Show help]"
          ;;
        status)
          _arguments \
            "--worktree-root[Worktree root]:directory:_directories" \
            {-h,--help}"[Show help]"
          ;;
        doctor)
          _arguments \
            "--worktree-root[Worktree root]:directory:_directories" \
            "--suggest[Ask apfel for fix suggestions]" \
            {-h,--help}"[Show help]"
          ;;
        mv|move)
          _message "move is interactive"
          ;;
        completion|-h|--help)
          _message "no arguments"
          ;;
      esac
      ;;
  esac
}

_wt_completion_script() {
  print -r -- "#compdef wt mkwt"
  print ""
  functions _wt_completion
  print ""
  print -r -- "compdef _wt_completion wt mkwt"
}

wt() {
  case "$1" in
    init)      shift; _wt_init "$@"; return ;;
    edit)      shift; _wt_edit "$@"; return ;;
    status)    shift; _wt_status "$@"; return ;;
    doctor)    shift; _wt_doctor "$@"; return ;;
    mv|move)   shift; _wt_mv   "$@"; return ;;
    completion) shift; _wt_completion_script; return ;;
    -h|--help)
      print "Usage: wt [init|edit|status|doctor|mv|move|completion] [-h|--help]"
      print ""
      print "  (bare)     pick a worktree group with fzf and cd into it"
      print "  init       create a new worktree group from one or more repos"
      print "  edit       remove selected worktrees from a worktree group"
      print "  status     show Starship prompts for worktrees"
      print "  doctor     check .git gitdir health and suggest fixes"
      print "  mv|move    move a worktree group to a new location"
      print "  completion print zsh completion script"
      return 0 ;;
  esac

  local wt_root="${bsl_wts:-$HOME/src/worktrees}"
  local wt_dir

  [[ -d "$wt_root" ]] || { print "Worktree base not found: $wt_root" >&2; return 1; }

  print "Select the worktree group to jump into."
  wt_dir=$(_wt_pick_worktree_root "Select worktree group") || return 0
  cd "$wt_dir"
}

alias mkwt='wt init'

if (( $+functions[compdef] )); then
  compdef _wt_completion wt mkwt
fi
