#!/usr/bin/env bash

set -euo pipefail

KUBE_CONTEXT=${3:-$(kubectl config current-context)}
DRY_RUN=${DRY_RUN:-"y"}
if [[ "$DRY_RUN" =~ ^([yY])+$ ]]; then
  DRY_RUN="--dry-run"
else
  DRY_RUN=""
fi

helmChartName='argo-cd'
helmReleaseName="argocd"
helmChartVersion='4.8.0'
helmChartRepo='https://argoproj.github.io/argo-helm'
chartNamespace="argocd-system"


command="install"

yq 'del(.server.ingress, .server.additionalApplications)' values.yaml > values.yaml.tmp

declare -a args=(
  $helmReleaseName
  $helmChartName
  '--create-namespace'
  '--debug'
  '--repo='$helmChartRepo''
  '--kube-context='$KUBE_CONTEXT''
  '--version '$helmChartVersion''
  '--wait'
  '-f ./values.yaml.tmp'
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
rm values.yaml.tmp
