#!/usr/bin/env bash

set -euo pipefail

COMMAND=${1:-"run"}

DOCKER_REPOSITORY="gcr.io/ronaldmiranda/dev-env"
DOCKER_IMAGE=${DOCKER_IMAGE:-"$DOCKER_REPOSITORY:202303260345-7d26673"}
BUILD_DOCKER_TAG=$(git log -n 1 --pretty='format:%cd-%h' --date=format:'%Y%m%d%H%M')

CONTAINER_NAME='devenv-personal'
DEVENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CONFIGURE=${ZSH_CONFIGURE:-"n"}

build() {
    docker build -t $DOCKER_REPOSITORY:$BUILD_DOCKER_TAG -f $DEVENV_DIR/dockerfile.base \
      $DEVENV_DIR
}

push() {
  docker buildx build --platform linux/arm64/v8,linux/amd64 \
    --push -t $DOCKER_REPOSITORY:$BUILD_DOCKER_TAG $DEVENV_DIR
}

run() {
  SYSTEM=$(uname)

  if [[ $SYSTEM == "Darwin" ]]; then
    GRP_CMD='useradd -ms /bin/zsh -d /home/$user -u $uid -g $gid $user'
    WORK_DIR="/home/$USER"
  else
    GRP_CMD='groupadd -g $gid $user && useradd -ms /bin/zsh -d /home/$user -u $uid -g $gid $user'
    WORK_DIR="$(pwd)"
  fi

  docker build -t local:1000 -f $DEVENV_DIR/dockerfile \
    --build-arg groupcmd="$GRP_CMD" \
    --build-arg image=$DOCKER_IMAGE \
    --build-arg user=$USER \
    --build-arg uid=$(id -u) \
    --build-arg gid=$(id -g) \
    --build-arg workdir=$WORK_DIR \
    $DEVENV_DIR

  declare -a args=(
    '--name '$CONTAINER_NAME''
    '--rm'
    '-e USR='$USER''
    '-e ZSH_CONFIGURE='$ZSH_CONFIGURE''
    '-e HOST_PLATFORM='$SYSTEM''
    '-it'
    '-v dev-env-pessoal:/home/'$USER''
    '-v '$HOME':/dojo/identity'
    '--net host'
    '--privileged'
  )

  if [[ "$SYSTEM" = "Darwin" ]]; then
    args+=(
      '-u '$(id -u $USER):$(id -g $USER)''
      '-e TZ='$(ls -la /etc/localtime | cut -d/ -f8-9)''
      # '-v /var/run/docker.sock:/var/run/docker.sock'
    )
    socat TCP-LISTEN:12346,reuseaddr,fork,bind=192.168.205.1 UNIX-CLIENT:$HOME/.rd/docker.sock &
    socat TCP-LISTEN:12345,reuseaddr,fork,bind=192.168.205.1 UNIX-CLIENT:$HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock &
  elif [[ "$SYSTEM" = "Linux" ]]; then
    args+=(
      '-v /var/run/docker.sock:/var/run/docker.sock'
      '-v '$(realpath /etc/localtime)':/etc/localtime:ro'
      '-v '$HOME'/.1password:/home/ronald/.1password'
      '-v /tmp/.X11-unix:/tmp/.X11-unix'
      '-e DISPLAY='$DISPLAY''
    )
  fi
  docker run ${args[*]} local:1000
}

case $COMMAND in
build)
  build
  ;;
push)
  push
  ;;
build-run)
  build
  run
  ;;
run)
  run
  ;;
esac
