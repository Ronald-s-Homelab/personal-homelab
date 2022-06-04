#!/usr/bin/env bash

declare -a args=(
  ''$ARGOCD_APP_NAME''
  ''$REPO_NAME'/'$CHART_NAME''
  ''$VALUE_FILES''
  '--version '$CHART_VERSION''
  '--namespace '$NAMESPACE''
)

helm template ${args[*]}
