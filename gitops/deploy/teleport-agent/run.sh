#!/usr/bin/env bash

set -euo pipefail

KUBE_CONTEXT=${3:-$(kubectl config current-context)}
DRY_RUN=${DRY_RUN:-"y"}

if [[ "$DRY_RUN" =~ ^([yY])+$ ]]; then
  DRY_RUN="--dry-run"
else
  DRY_RUN=""
fi

helmReleaseName="teleport-agent"
helmChartRepo='../../stable/teleport-agent'
chartNamespace="teleport-system"

command="install"

declare -a args=(
  $helmReleaseName
  $helmChartRepo
  '--create-namespace'
  '--debug'
  '--kube-context='$KUBE_CONTEXT''
  '--wait'
  '-f ./oracle.yaml'
  '-n='$chartNamespace''
  $DRY_RUN
)

if [[ $(helm list -n $chartNamespace -o json | \
    jq -r '.[] | select(.name=="'$helmReleaseName'") | true') == true ]];then
  command="upgrade"
  args+=('--install' '--reset-values')
else
  args+=('--replace')
fi

echo "Installing/Upgrading Helm Chart ${helmReleaseName} in ${KUBE_CONTEXT} Context Kubernetes"
helm $command ${args[*]}
