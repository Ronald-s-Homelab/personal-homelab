#!/usr/bin/env bash

set -euo pipefail


IMAGE="ronaldmiranda/atlantis:0.30"
ATLANTIS="0.19.8"
TERRAGRUNT="0.38.9"
TERRAFORM="1.2.0"
TERRAGRUNT_ATLANTIS_CONFIG="1.15.0"

docker buildx build --platform linux/arm64 -t ${IMAGE} \
  --build-arg=ATLANTIS=${ATLANTIS} \
  --build-arg=TERRAGRUNT=${TERRAGRUNT} \
  --build-arg=TERRAFORM=${TERRAFORM} \
  --build-arg=TERRAGRUNT_ATLANTIS_CONFIG=${TERRAGRUNT_ATLANTIS_CONFIG} \
  .

docker push ${IMAGE}
