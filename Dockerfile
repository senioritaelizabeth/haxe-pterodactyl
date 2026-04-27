FROM haxe:latest

# HashLink y dependencias necesarias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libturbojpeg-dev \
    libvorbis-dev \
    libopenal-dev \
    libsdl2-dev \
    libmbedtls-dev \
    libuv1-dev \
    git \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Setup haxelib
RUN mkdir -p /haxelib && haxelib setup /haxelib

WORKDIR /home/container