#!/usr/bin/env sh

echo "This will install chezmoi and github.com/blehrer/dotfiles"
cd ~/.local
echo "... Installing ~/.local/bin/chezmoi"
sh -c "$(curl -fsLS get.chezmoi.io)"
echo "... Cloning dotfiles to ~/.local/share/chezmoi"
./bin/chezmoi init --apply blehrer
