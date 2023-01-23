#!/usr/bin/env bash

function xit-down() {
  local processIds
  processIds=$(jps -l | grep xit.jar | awk '{print $1}')
  echo "Killing xit.jar(s) ($processIds)"
  for pid in ${processIds//\\n/ }; do
    kill "$pid"
  done
}
xit-down
