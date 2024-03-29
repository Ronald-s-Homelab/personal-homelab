#!/usr/bin/env bash

set -euo pipefail

STABLE_DOCKER_TAG=$(git log -n 1 --pretty='format:%cd-%h' --date=format:'%Y%m%d%H%M')
DOCKER_REPOSITORY="gcr.io/ronaldmiranda/dev-env"
DOCKER_IMAGE=$DOCKER_REPOSITORY:$STABLE_DOCKER_TAG
DEVENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DEVENV_DIR/run.sh build-run
