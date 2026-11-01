FROM antmicro/renode:latest

USER root

RUN echo Acquire::Queue-Mode "host"; >> /etc/apt/apt.conf.d/99parallel && \
    echo Acquire::http::Pipeline-Depth "5"; >> /etc/apt/apt.conf.d/99parallel

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends -o Dpkg::Options::="--force-overwrite" \
      git \
      python3 python3-pip pipx \
      lcov \
      gcc-arm-none-eabi gdb-multiarch build-essential make && \
      rm -rf /var/lib/apt/lists/*

COPY execution_tracer /tools/execution_tracer
RUN --mount=type=cache,target=/root/.cache/pip \ 
    pip install /tools/execution_tracer --break-system-packages

USER ubuntu
