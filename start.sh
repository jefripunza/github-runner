#!/bin/bash
set -e

if [ -S "/var/run/docker.sock" ]; then
  DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
  if ! getent group "$DOCKER_GID" >/dev/null 2>&1; then
    groupadd -g "$DOCKER_GID" docker
  fi
  usermod -aG "$DOCKER_GID" runner
fi

if [ -z "$REPO_URL" ]; then
  echo "REPO_URL not set"
  exit 1
fi

if [ -z "$RUNNER_TOKEN" ]; then
  echo "RUNNER_TOKEN not set"
  exit 1
fi

./config.sh \
  --url $REPO_URL \
  --token $RUNNER_TOKEN \
  --name docker-runner \
  --work _work \
  --unattended \
  --replace

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token $RUNNER_TOKEN
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

exec gosu runner:runner ./run.sh
