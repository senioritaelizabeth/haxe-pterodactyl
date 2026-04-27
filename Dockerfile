FROM alpine:3.23

ENV PATH=/usr/local/bin:$PATH \
    USER=container \
    HOME=/home/container \
    HAXE_STD_PATH=/usr/local/share/haxe/std

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    tini \
    tar \
    unzip \
    zip \
    tzdata \
    sqlite \
    sqlite-dev \
    libuv \
    libuv-dev \
    mbedtls \
    mbedtls-dev \
    libpng \
    libpng-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libvorbis \
    libvorbis-dev \
    openal-soft \
    openal-soft-dev \
    sdl2 \
    sdl2-dev \
    iproute2 \
    dnsutils \
    iputils \
    build-base \
    cmake \
    ninja \
    linux-headers \
    musl-dev \
    gc-dev \
    pcre2-dev \
    mariadb-dev \
    apache2-dev \
    opam \
    aspcud \
    m4 \
    pkgconf \
    rsync \
    perl-string-shellquote \
    perl-ipc-system-simple \
    ocaml-compiler-libs \
    ocaml-ocamldoc \
    && adduser -D -h /home/container container

WORKDIR /usr/src

# Neko
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

# Haxe
RUN git clone --recursive --depth 1 --branch 4.3.7 "https://github.com/HaxeFoundation/haxe.git" /usr/src/haxe \
    && cd /usr/src/haxe \
    && mkdir -p $HAXE_STD_PATH \
    && cp -r std/* $HAXE_STD_PATH \
    && opam init --compiler=4.14.2 --disable-sandboxing \
    && eval $(opam env --switch=4.14.2) \
    && opam pin add luv 0.5.14 --no-action \
    && opam pin add haxe . --no-action \
    && opam install haxe --deps-only --no-depexts --yes --ignore-constraints-on=luv \
    && make \
    && cp haxe haxelib /usr/local/bin \
    && mkdir -p /haxelib \
    && haxelib setup /haxelib \
    && eval $(opam env --revert) \
    && rm -rf ~/.opam /usr/src/haxe

WORKDIR /home/container

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
    && chown -R container:container /home/container /haxelib

USER container

STOPSIGNAL SIGINT

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
