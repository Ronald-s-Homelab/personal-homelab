#!/usr/bin/env bash

set -euo pipefail

KUBE_CONTEXT=${3:-$(kubectl config current-context)}
DRY_RUN=${DRY_RUN:-"y"}
CREATE_SECRET=${CREATE_SECRET:-"n"}
DOPPLER_TOKEN=$(op read op://cli/doppler-oracle/password)

if [[ "$DRY_RUN" =~ ^([yY])+$ ]]; then
  DRY_RUN="--dry-run"
else
  DRY_RUN=""
fi

helmReleaseName="common"
helmChartRepo='../../stable/common'
chartNamespace="external-secrets-system"
secretNamespace='external-secrets-system'

if [[ "$CREATE_SECRET" =~ ^([nN])+$ ]]; then
  CREATE_SECRET=""
else
  CREATE_SECRET="kubectl create secret generic doppler-token-auth-api $DRY_RUN -n $secretNamespace --from-literal dopplerToken="$DOPPLER_TOKEN""
fi

command="install"

eval $CREATE_SECRET

declare -a args=(
  $helmReleaseName
  $helmChartRepo
  '--create-namespace'
  '--debug'
  '--kube-context='$KUBE_CONTEXT''
  '--wait'
  '-f ./values.yaml'
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
