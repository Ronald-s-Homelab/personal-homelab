#!/usr/bin/env bash

set -euo pipefail

COMMAND=${1:-"run"}

DOCKER_REPOSITORY="ronaldmiranda/dev-env"
DOCKER_IMAGE=${DOCKER_IMAGE:-"$DOCKER_REPOSITORY:202204111109-9a8384c"}
DOCKER_ARM_IMAGE=${DOCKER_ARM_IMAGE:-"$DOCKER_REPOSITORY:202302092212-6e14ccc"}
BUILD_DOCKER_TAG=$(git log -n 1 --pretty='format:%cd-%h' --date=format:'%Y%m%d%H%M')

CONTAINER_NAME='devenv-personal'
DEVENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ZSH_CONFIGURE=${ZSH_CONFIGURE:-"n"}

_checkCPUPlatform() {
  case $(uname -m) in
    aarch64)
      DOCKER_IMAGE=$DOCKER_ARM_IMAGE
      ARCH='arm64';;
    arm64)
      DOCKER_IMAGE=$DOCKER_ARM_IMAGE
      ARCH='arm64';;
    x86_64)
      DOCKER_IMAGE=$DOCKER_IMAGE
      ARCH='amd64';;
    amd64)
      DOCKER_IMAGE=$DOCKER_IMAGE
      ARCH='amd64';;
  esac
}

build(){
  if [[ $(uname -m) == 'aarch64' ]] || [[ $(uname -m) == 'arm64' ]]; then
    docker build -t $DOCKER_REPOSITORY:$BUILD_DOCKER_TAG \
      -f $DEVENV_DIR/dockerfile.arm.base \
      $DEVENV_DIR
  else
    docker build -t $DOCKER_REPOSITORY:$BUILD_DOCKER_TAG -f $DEVENV_DIR/dockerfile.base \
      $DEVENV_DIR
  fi
}

push(){
  docker push $DOCKER_REPOSITORY:$BUILD_DOCKER_TAG
}

run(){
  _checkCPUPlatform

  if [[ $(uname) == "Darwin" ]]; then
    GRP_CMD='useradd -ms /bin/zsh -d /home/$user -u $uid -g $gid $user'
  else
    GRP_CMD='groupadd -g $gid $user && useradd -ms /bin/zsh -d /home/$user -u $uid -g $gid $user'
  fi

  docker build -t local:1000 -f $DEVENV_DIR/dockerfile \
    --build-arg groupcmd="$GRP_CMD" \
    --build-arg image=$DOCKER_IMAGE \
    --build-arg user=$USER \
    --build-arg arch=$ARCH \
    --build-arg uid=$(id -u) \
    --build-arg gid=$(id -g) \
    $DEVENV_DIR

  declare -a args=(
    '--name '$CONTAINER_NAME''
    '--rm'
    '-e USR='$USER''
    '-e ZSH_CONFIGURE='$ZSH_CONFIGURE''
    '-it'
    '-v dev-env-pessoal:/home/'$USER''
    '-v '$HOME':/dojo/identity'
    '--net host'
    '--privileged'
  )

  if [[ "$(uname)" = "Darwin" ]]; then
    args+=(
      '-e SSH_AUTH_SOCK=/mnt/sock/agent.sock'
      '-u '$(id -u $USER):$(id -g $USER)''
      '-e TZ='$(ls -la /etc/localtime | cut -d/ -f8-9)''
    )
    socat TCP-LISTEN:12345,reuseaddr,fork,bind=192.168.205.1 UNIX-CLIENT:$HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock &
  elif [[ "$(uname)" = "Linux" ]]; then
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
    build;;
  push)
    push;;
  build-push)
    build
    push;;
  build-run)
    build
    run;;
  run)
    run;;
esac
