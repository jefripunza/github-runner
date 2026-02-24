#!/bin/bash
set -e

if [ -S "/var/run/docker.sock" ]; then
  DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
  DOCKER_GROUP_NAME=""

  if getent group docker >/dev/null 2>&1; then
    EXISTING_DOCKER_GID=$(getent group docker | cut -d: -f3)
    if [ "$EXISTING_DOCKER_GID" = "$DOCKER_GID" ]; then
      DOCKER_GROUP_NAME="docker"
    fi
  fi

  if [ -z "$DOCKER_GROUP_NAME" ] && getent group "$DOCKER_GID" >/dev/null 2>&1; then
    DOCKER_GROUP_NAME=$(getent group "$DOCKER_GID" | head -n1 | cut -d: -f1)
  fi

  if [ -z "$DOCKER_GROUP_NAME" ]; then
    DOCKER_GROUP_NAME="docker-host"
    if ! getent group "$DOCKER_GROUP_NAME" >/dev/null 2>&1; then
      groupadd -g "$DOCKER_GID" "$DOCKER_GROUP_NAME"
    fi
  fi

  usermod -aG "$DOCKER_GROUP_NAME" runner
fi

if [ -z "$REPO_URL" ]; then
  echo "REPO_URL not set"
  exit 1
fi

if [ -z "$RUNNER_TOKEN" ]; then
  echo "RUNNER_TOKEN not set"
  exit 1
fi

gosu runner:runner ./config.sh \
  --url $REPO_URL \
  --token $RUNNER_TOKEN \
  --name docker-runner \
  --work _work \
  --unattended \
  --replace

cleanup() {
  echo "Removing runner..."
  gosu runner:runner ./config.sh remove --unattended --token $RUNNER_TOKEN
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

exec gosu runner:runner ./run.sh
