`xit` is a command line utility for doing common tasks with this java project that were written instead of taking on the
additional challenge of learning Gradle while translating workflow ideas into scripts. Also, because how lovely is it to
have completion, instead of using `./gradlew`?

# Installation

Run this from within your local copy of the xit repo.

Be sure to set `init_script` to your preferred init-script.

```sh
gitdir=$(git rev-parse --show-toplevel)
init_script=~/.nbcu-secrets
[[ $(git remote get-url origin) = *OnAirSystems/xit.git ]] && {
echo "
### xit cli
source $gitdir/src/main/scripts/local/cli/xit
source $gitdir/src/main/scripts/local/cli/completion/xit-completion.bash
" >> $init_script && source $init_script
} || {
    echo "You need to run this from ${gitdir:-'within a copy of the xit repo'}"
    return 1
}
unset gitdir
source $init_script
unset init_script

```

# Complimentary projects

- [jEnv](https://www.jenv.be/)

# Usage

```terminal
$ pwd
/path/to/github.inbcu.com/OnAirSystems/xit

$ xit [tab-complete]
```
