FROM docker:dind

ENV RUNNER_VERSION=2.331.0

RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    sudo \
    su-exec \
    shadow \
    icu-libs \
    openssl \
    zlib \
    gcc \
    musl-dev \
    libstdc++

RUN adduser -D -h /home/runner runner \
    && addgroup runner docker

WORKDIR /home/runner

RUN curl -o actions-runner-linux-x64.tar.gz -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner-linux-x64.tar.gz \
    && rm actions-runner-linux-x64.tar.gz \
    && chown -R runner:runner /home/runner

COPY --chown=runner:runner start.sh /home/runner/start.sh
RUN chmod +x /home/runner/start.sh

VOLUME /var/lib/docker

ENTRYPOINT ["/home/runner/start.sh"]