/usr/bin/env bash
# ssh2config - utility for converting ssh commands to configurations
#
# Author: Michael Slattery, https://serverfault.com/a/1064320/1018389
#
# Example use:
# $ ssh2config -p 2222 me@there
# there
#    hostname there
#    port 2222
#    user me
ssh2config() {
  host="$(ssh -G "$@" | sed -n 's/^hostname //p')"
  echo "$host"
  comm -23 <(ssh -G "$@" | sort) <(ssh -G abcddd | sort) | sed 's/^/    /'
  echo ''
}
