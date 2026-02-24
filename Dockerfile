FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_VERSION=2.314.1

RUN apt update && apt install -y \
    curl \
    jq \
    git \
    build-essential \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m runner
WORKDIR /home/runner

RUN curl -o actions-runner-linux-x64.tar.gz -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN tar xzf ./actions-runner-linux-x64.tar.gz

RUN chown -R runner:runner /home/runner

USER runner

COPY start.sh .
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]
