FROM --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL author="MDC" maintainer="me@mdcdev.me"

ENV DEBIAN_FRONTEND=noninteractive \
    USER=container \
    HOME=/home/container \
    PATH=/usr/local/bin:$PATH \
    HAXE_STD_PATH=/usr/local/share/haxe/std \
    NEKO_VERSION=2.4.1 \
    HAXE_VERSION=4.3.7

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    git \
    unzip \
    zip \
    tar \
    xz-utils \
    bash \
    tini \
    tzdata \
    dnsutils \
    iproute2 \
    iputils-ping \
    sqlite3 \
    libsqlite3-dev \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    rsync \
    m4 \
    opam \
    aspcud \
    ocaml \
    ocaml-findlib \
    libgc-dev \
    libpcre2-dev \
    libmbedtls-dev \
    libmariadb-dev \
    libapache2-mod-php \
    zlib1g-dev \
    libpng-dev \
    libturbojpeg-dev \
    libvorbis-dev \
    libopenal-dev \
    libsdl2-dev \
    libglu1-mesa-dev \
    libuv1-dev \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -d /home/container container

WORKDIR /usr/src

RUN wget -O neko.tar.gz "https://github.com/HaxeFoundation/neko/archive/v2-4-1/neko-2.4.1.tar.gz" \
    && echo "702282028190dffa2078b00cca515b8e2ba889186a221df2226d2b6deb3ffaca *neko.tar.gz" | sha256sum -c - \
    && mkdir neko \
    && tar -xC neko --strip-components=1 -f neko.tar.gz \
    && cd neko \
    && cmake -GNinja -DNEKO_JIT_DISABLE=ON -DRELOCATABLE=OFF -DRUN_LDCONFIG=OFF . \
    && ninja \
    && ninja install \
    && cd /usr/src \
    && rm -rf neko neko.tar.gz

RUN git clone --recursive --depth 1 --branch ${HAXE_VERSION} "https://github.com/HaxeFoundation/haxe.git" /usr/src/haxe \
    && cd /usr/src/haxe \
    && mkdir -p ${HAXE_STD_PATH} \
    && cp -r std/* ${HAXE_STD_PATH} \
    && opam init --disable-sandboxing -y \
    && eval $(opam env) \
    && opam switch create 4.14.2 -y \
    && eval $(opam env) \
    && opam pin add luv 0.5.14 --no-action -y \
    && opam pin add haxe . --no-action -y \
    && opam install haxe --deps-only --yes --ignore-constraints-on=luv \
    && make \
    && cp haxe haxelib /usr/local/bin \
    && mkdir -p /haxelib \
    && haxelib setup /haxelib \
    && rm -rf /root/.opam /usr/src/haxe

WORKDIR /home/container

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
    && chown -R container:container /home/container /haxelib

USER container

STOPSIGNAL SIGINT

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
