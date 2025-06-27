# ChezMoi dotfiles

- [ChezMoi docs](https://www.chezmoi.io/reference/)
- [ChezMoi reference implementation](https://github.com/twpayne/dotfiles)

## Install

```sh"
RTP=$HOME/.local/bin"
if [ $(echo ${PATH} | grep "$RTP")] && [[ 'bin' = $(basename $RTP)]]; then
    cd $(dirname $RTP)
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply blehrer
fi
```
