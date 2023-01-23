#!/usr/bin/env bash

[ -d ~/.cache/xit ] || mkdir -p ~/.cache/xit
[ -f ~/.cache/xit/installation.err.log ] && rm ~/.cache/xit/installation.err.log
cd "$XIT_INSTALL_DIR" && ./shutdown.sh
cd $GITDIR || return 1
./gradlew dist
rm -rfd "${XIT_INSTALL_DIR}/*[^home,shutdown.sh]"
mkdir -p "${XIT_INSTALL_DIR}/{logs,home/packages}"
cp "${GITDIR}/.env" "${XIT_INSTALL_DIR}"
cp "${XIT_SECRET_CONFIGURATION_PROPERTIES}" "${XIT_HOME_DIR}/configuration.properties"
cd "${XIT_INSTALL_DIR}" || return 1

# Simplify your life with [jEnv](https://www.jenv.be/)
[ "$(which jenv)" ] && jenv local 1.8

"${GITDIR}/dist/install.sh" "${GITDIR}/dist/xit*.zip" 2>~/.cache/xit/installation.err.log
[ -S ~/.cache/xit/installation.err.log ] && {
  echo ~/.cache/xit/installation.err.log
  echo ---------
  cat ~/.cache/xit/installation.err.log
} || rm ~/.cache/xit/installation.err.log
cd "${XIT_INSTALL_DIR}" || return 1
