#!/usr/bin/env zsh

## Install Homebrew
if [ ! $(command -v brew) ]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	if [ -z ~/.zprofile ] || [ ! $(cat ~/.zprofile | grep -q 'brew shellenv')]; then
		echo >> ~/.zprofile
		echo 'eval "$(${HOMEBREW_PREFIX:-/opt/homebrew}/bin/brew shellenv)"' >> ~/.zprofile
		eval "$(${HOMEBREW_PREFIX:-/opt/homebrew}/bin/brew shellenv)"
	fi
fi
source ~/.zprofile
${HOMEBREW_PREFIX:-/opt/homebrew}/bin/brew install chezmoi
chezmoi init --apply blehrer
