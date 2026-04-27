FROM --platform=linux/amd64 debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    USER=container \
    HOME=/home/container \
    PATH=/usr/local/bin:$PATH

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    bash \
    tini \
    unzip \
    zip \
    tar \
    tzdata \
    libmbedtls-dev \
    libuv1-dev \
    libpng-dev \
    libturbojpeg-dev \
    libvorbis-dev \
    libopenal-dev \
    libsdl2-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -d /home/container container

WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
