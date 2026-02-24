#!/bin/bash

DOCKERD_PID=""

stop_dockerd() {
  if [ -n "$DOCKERD_PID" ]; then
    echo "Stopping Docker daemon..."
    kill "$DOCKERD_PID" 2>/dev/null || true
    wait "$DOCKERD_PID" 2>/dev/null || true
  fi
}

trap stop_dockerd EXIT

if [ -z "$REPO_URL" ]; then
  echo "REPO_URL not set"
  exit 1
fi

if [ -z "$RUNNER_TOKEN" ]; then
  echo "RUNNER_TOKEN not set"
  exit 1
fi

rm -f /var/run/docker.pid

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

if ! gosu runner ./config.sh \
  --url "$REPO_URL" \
  --token "$RUNNER_TOKEN" \
  --name docker-runner \
  --work _work \
  --unattended \
  --replace; then
  echo "Runner registration failed. Check REPO_URL and RUNNER_TOKEN."
  exit 1
fi

cleanup() {
  echo "Removing runner..."
  gosu runner ./config.sh remove --unattended --token "$RUNNER_TOKEN" || true
}

trap 'cleanup; stop_dockerd; exit 130' INT
trap 'cleanup; stop_dockerd; exit 143' TERM

gosu runner ./run.sh &
RUNNER_PID=$!

wait $RUNNER_PID
