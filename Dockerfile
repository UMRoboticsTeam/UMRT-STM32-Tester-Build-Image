FROM ubuntu:24.04

ARG TARGETARCH

RUN echo Acquire::Queue-Mode "host"; >> /etc/apt/apt.conf.d/99parallel && \
    echo Acquire::http::Pipeline-Depth "5"; >> /etc/apt/apt.conf.d/99parallel
 
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends -o Dpkg::Options::="--force-overwrite" \
      build-essential \
      cmake \
      file \
      gcc-arm-none-eabi \
      gdb-multiarch \
      gh \
      git \
      lcov \
      libc6-dev \
      libicu-dev \
      libnewlib-arm-none-eabi \
      make \
      pipx \
      policykit-1 \
      python3 \
      python3-dev \
      python3-pip \
      screen \
      uml-utilities \
      xz-utils && \
      rm -rf /var/lib/apt/lists/*
      
# INSTALLING RENODE ON ARM/LINUX
COPY renode/renode-1.16.1.linux-arm64-portable-dotnet.tar.gz /renode/renode-1.16.1.linux-arm64-portable-dotnet.tar.gz
COPY renode/renode-1.16.1.linux-portable-dotnet.tar.gz /renode/renode-1.16.1.linux-portable-dotnet.tar.gz

RUN mkdir -p /opt/renode && \
    if [ "$TARGETARCH" = "arm64" ] ; then \
       tar -xzf /renode/renode-1.16.1.linux-arm64-portable-dotnet.tar.gz -C /opt/renode --strip-components=1 ; \
    else \
       tar -xzf /renode/renode-1.16.1.linux-portable-dotnet.tar.gz -C /opt/renode --strip-components=1 ; \
    fi && \
    rm -rf /renode

# INSTALLING RENODE RETRACER AND RENODE-TEST REQUIREMENTS 
COPY renode/execution_tracer /tools/execution_tracer
RUN --mount=type=cache,target=/root/.cache/pip \ 
    pip install --break-system-packages --no-cache-dir \
    -r /opt/renode/tests/requirements.txt \
    /tools/execution_tracer
    
ENV PATH="/opt/renode:${PATH}"
CMD ["renode"]
