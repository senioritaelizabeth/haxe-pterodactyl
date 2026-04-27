FROM --platform=linux/amd64 debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    USER=container \
    HOME=/home/container \
    PATH=/usr/local/bin:$PATH \
    HAXE_VERSION=4.3.7 \
    NEKO_VERSION=2.4.1

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    git \
    bash \
    tini \
    unzip \
    zip \
    tar \
    tzdata \
    libmbedtls-dev \
    libuv1 \
    libuv1-dev \
    libpng-dev \
    libturbojpeg-dev \
    libvorbis-dev \
    libopenal-dev \
    libsdl2-dev \
    libsqlite3-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -d /home/container container

WORKDIR /usr/src

# Neko from source release tarball
RUN wget -O neko.tar.gz "https://github.com/HaxeFoundation/neko/archive/v2-4-1/neko-2.4.1.tar.gz" \
    && mkdir -p /usr/src/neko \
    && tar -xC /usr/src/neko --strip-components=1 -f neko.tar.gz \
    && rm neko.tar.gz \
    && cd /usr/src/neko \
    && mkdir build && cd build \
    && cmake -DRELOCATABLE=OFF -DNEKO_JIT_DISABLE=ON .. \
    && cmake --build . -j"$(nproc)" \
    && cmake --install . \
    && cd /usr/src \
    && rm -rf /usr/src/neko

# Haxe binary release
RUN mkdir -p /usr/src/haxe \
    && cd /usr/src/haxe \
    && wget -O haxe.tar.gz "https://github.com/HaxeFoundation/haxe/releases/download/${HAXE_VERSION}/haxe-${HAXE_VERSION}-linux64.tar.gz" \
    && tar -xzf haxe.tar.gz --strip-components=1 \
    && rm haxe.tar.gz \
    && cp haxe haxelib /usr/local/bin/ \
    && mkdir -p /usr/local/share/haxe \
    && cp -r std /usr/local/share/haxe/std \
    && rm -rf /usr/src/haxe

RUN mkdir -p /haxelib && chown -R container:container /haxelib /home/container

WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
