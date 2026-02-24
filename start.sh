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

echo "Starting Docker daemon..."
dockerd &
DOCKERD_PID=$!

echo "Waiting for Docker daemon to be ready..."
TRIES=0
MAX_TRIES=30
until docker info >/dev/null 2>&1; do
  TRIES=$((TRIES + 1))
  if [ $TRIES -ge $MAX_TRIES ]; then
    echo "Docker daemon failed to start after ${MAX_TRIES}s"
    exit 1
  fi
  sleep 1
done
echo "Docker daemon is ready."

su-exec runner ./config.sh \
  --url $REPO_URL \
  --token $RUNNER_TOKEN \
  --name docker-runner \
  --work _work \
  --unattended \
  --replace

cleanup() {
  echo "Removing runner..."
  su-exec runner ./config.sh remove --unattended --token $RUNNER_TOKEN
  kill $DOCKERD_PID 2>/dev/null || true
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

su-exec runner ./run.sh &
RUNNER_PID=$!

wait $RUNNER_PID
