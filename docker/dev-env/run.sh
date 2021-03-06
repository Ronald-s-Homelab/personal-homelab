#!/usr/bin/env bash

set -euo pipefail

COMMAND=${1:-"run"}

DOCKER_REPOSITORY="ronaldmiranda/dev-env"
DOCKER_IMAGE=${DOCKER_IMAGE:-"$DOCKER_REPOSITORY:202204111109-9a8384c"}
DOCKER_ARM_IMAGE=${DOCKER_ARM_IMAGE:-"$DOCKER_REPOSITORY:202206191535-9eb94c8"}
BUILD_DOCKER_TAG=$(git log -n 1 --pretty='format:%cd-%h' --date=format:'%Y%m%d%H%M')

CONTAINER_NAME='devenv-personal'
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
      -f dockerfile.arm.base \
      $( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  else
    docker build -t $DOCKER_REPOSITORY:$BUILD_DOCKER_TAG -f dockerfile.base \
      $( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  fi
}

push(){
  docker push $DOCKER_REPOSITORY:$BUILD_DOCKER_TAG
}

socatRun() {
  declare -a socatArgs=(
    '--name socat'
    '-i'
    '-d'
    '--restart=always'
    '-u '$(id -u $USER):$(id -g $USER)''
    '-v sock-volume:/mnt/sock'
  )

  if [ ! "$(docker ps -q -f name=socat)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=socat)" ]; then
        # cleanup
        docker rm socat
    fi
    docker run ${socatArgs[*]} \
      alpine/socat UNIX-LISTEN:/mnt/sock/agent.sock,reuseaddr,fork TCP:192.168.205.1:12345
  fi
}

run(){
  _checkCPUPlatform

  if [[ $(uname) == "Darwin" ]]; then
    GRP_CMD='useradd -ms /bin/zsh -d /home/$user -u $uid -g $gid $user'
  else
    GRP_CMD='groupadd -g $gid $user && useradd -ms /bin/zsh -d /home/$user -u $uid -g $gid $user'
  fi

  docker build -t local:1000 -f dockerfile \
    --build-arg groupcmd="$GRP_CMD" \
    --build-arg image=$DOCKER_IMAGE \
    --build-arg user=$USER \
    --build-arg arch=$ARCH \
    --build-arg uid=$(id -u) \
    --build-arg gid=$(id -g) \
    $( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

  declare -a args=(
    '--name '$CONTAINER_NAME''
    '--rm'
    '-e USR='$USER''
    '-e ZSH_CONFIGURE='$ZSH_CONFIGURE''
    '-it'
    '-v dev-env-pessoal:/home/'$USER''
    '-v '$HOME':/dojo/identity'
    '--net host'
  )

  if [[ "$(uname)" = "Darwin" ]]; then
    args+=(
      '-u '$(id -u $USER):$(id -g $USER)''
      '-e TZ='$(ls -la /etc/localtime | cut -d/ -f8-9)''
      '-v sock-volume:/mnt/sock'
    )
    socat TCP-LISTEN:12345,reuseaddr,fork,bind=192.168.205.1 UNIX-CLIENT:/tmp/agent.sock &
    socatRun &
  elif [[ "$(uname)" = "Linux" ]]; then
    args+=('
      -v '$(realpath /etc/localtime)':/etc/localtime:ro'
      '-v '$HOME'/.1password:/home/ronald/.1password'
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
  run)
    run;;
esac
