#!/usr/bin/env bash
function _xit_completions() {
  supported+=' help'
  supported+=' down'
  supported+=' clean'
  supported+=' js-clean'
  supported+=' install'
  supported+=' tll-gen-run'
  supported+=' recon-gen'
  COMPREPLY=("$(compgen -W "${supported}" "${COMP_WORDS[1]}")")
}

complete -F _xit_completions xit
