#!/usr/bin/env bash

procname=$1
pkill ${procname}
eval "${procname}"
rc=$?
unset procname
return $rc

