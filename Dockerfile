FROM debian:bookworm-slim

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
    libpng-dev \
    libturbojpeg-dev \
    libvorbis-dev \
    libopenal-dev \
    libsdl2-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -d /home/container container

WORKDIR /usr/src

RUN mkdir -p /usr/local/share/haxe \
    && wget -O haxe.tar.gz "https://github.com/HaxeFoundation/haxe/releases/download/${HAXE_VERSION}/haxe-${HAXE_VERSION}-linux64.tar.gz" \
    && tar -xzf haxe.tar.gz -C /usr/local/share/haxe --strip-components=1 \
    && rm haxe.tar.gz \
    && ln -s /usr/local/share/haxe/haxe /usr/local/bin/haxe \
    && ln -s /usr/local/share/haxe/haxelib /usr/local/bin/haxelib

# If you have a direct Neko binary release URL, replace this block with that release.
# If not, keep Neko out of build-time compilation and install it from a known package/source.
# Example placeholder:
# RUN wget -O neko.tar.gz "https://github.com/HaxeFoundation/neko/releases/download/v${NEKO_VERSION}/neko-${NEKO_VERSION}-linux64.tar.gz" \
#     && ...

RUN mkdir -p /haxelib && chown -R container:container /haxelib /home/container

WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
