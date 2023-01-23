#!/usr/bin/env bash

xit() {
    readonly usage="
xit [command]

Commands

help               Show this
down               Turn it off
clean              Clean up server build
js-clean           Clean up UI build
install            Install it, heeding .env
tll-gen-run        Generate tll packages
recon-gen
generate
"
    GITDIR=$(git rev-parse --show-toplevel)
    [ $? ] && [[ $(git remote get-url origin) = *OnAirSystems/xit.git ]] || {
        echo "Must be run with xit repo"
        return 1
    }

    cmd=$1
    [ $cmd ] || {
        echo "
        Supported actions:
            help
            down
            clean
            js-clean
            install
            tll-gen-run
            recon-gen
            generate
        "
        return 1
    }

    readonly LIBS=$GITDIR/src/main/scripts/local/cli/lib
    [[ $cmd = 'help' ]] && { echo $usage ; return }
    [[ $cmd = 'up' ]] && { source $LIBS/xit-up.bash $2 ; return }
    [[ $cmd = 'down' ]] && { source $LIBS/xit-down.bash ; return }
    [[ $cmd = 'clean' ]] && { source $LIBS/xit-clean.bash.bash ; return }
    [[ $cmd = 'js-clean' ]] && { source $LIBS/xit-js-clean.bash ; return }
    [[ $cmd = 'java-clean' ]] && { source $LIBS/xit-java-clean.bash; return }
    [[ $cmd = 'build' ]] && { source $LIBS/xit-dist.bash ; return }
    [[ $cmd = 'install' ]] && { source $LIBS/xit-install.bash ; return }
    [[ $cmd = 'tll-gen-run' ]] && { source $LIBS/xit-tll-gen-run.bash ; return }
    [[ $cmd = 'recon-gen' ]] && { source $LIBS/xit-recon-gen.bash ; return }
    [[ $cmd = 'generate' ]] && { echo "$cmd not supported yet" ; return 1 }
    echo $cmd not supported
    echo $usage
    return 1
}
