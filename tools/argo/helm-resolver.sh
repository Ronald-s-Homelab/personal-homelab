#!/usr/bin/env bash

declare -a args=(
  ''$ARGOCD_APP_NAME''
  ''$ARGOCD_ENV_REPO_NAME'/'$ARGOCD_ENV_CHART_NAME''
  ''$ARGOCD_ENV_VALUE_FILES''
  '--version '$ARGOCD_ENV_CHART_VERSION''
  '--namespace '$ARGOCD_ENV_NAMESPACE''
)

helm template ${args[*]}
