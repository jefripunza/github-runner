#!/bin/bash
set -e

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

./run.sh
