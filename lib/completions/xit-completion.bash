#!/usr/bin/env bash

function _xit_completions() {
    COMPREPLY=($(compgen -W "up down clean java-clean js-clean build install tll-gen-run" "${COMP_WORDS[1]}"))
}

complete -F _xit_completions xit
