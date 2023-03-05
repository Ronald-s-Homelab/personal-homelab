#!/usr/bin/env bash

set -euo pipefail

STABLE_DOCKER_TAG=$(git log -n 1 --pretty='format:%cd-%h' --date=format:'%Y%m%d%H%M')

DOCKER_REPOSITORY="ronaldmiranda/dev-env"

DOCKER_IMAGE=$DOCKER_REPOSITORY:$STABLE_DOCKER_TAG DOCKER_ARM_IMAGE=$DOCKER_REPOSITORY:$STABLE_DOCKER_TAG \
  ./run.sh build-run

