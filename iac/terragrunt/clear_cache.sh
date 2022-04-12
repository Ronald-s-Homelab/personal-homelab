#!/usr/bin/env bash

set -euo pipefail

pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CMD=${1-:""}

clean() {
  FORCE=${1-:"false"}
  cmd="echo"

  if [[ $FORCE = "true" ]]; then
    cmd="rm -rf"
  fi

  $cmd $(find . -name ".terraform.lock.hcl")
  $cmd $(find . -type d -name ".terragrunt-cache")
}

case $CMD in
clean)
  clean true
  ;;
*)
  clean
  ;;
esac
