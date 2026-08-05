# =============================================================================
# Cross-compile shadowsocks-libev statically for Linux ARM64 (aarch64)
# Usage:
#   docker build --platform linux/amd64 -t ss-libev-arm64 -f docker/arm64-static/Dockerfile .
#   docker create --name ss-tmp ss-libev-arm64
#   docker cp ss-tmp:/output ./arm64-output
#   docker rm ss-tmp
# =============================================================================

FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TARGET=aarch64-linux-gnu
ENV PREFIX=/opt/aarch64

# --------------------------------------------------------------------------
# 1. Install cross-compiler and build tools
# --------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu \
        cmake \
        make \
        autoconf \
        automake \
        libtool \
        pkg-config \
        ca-certificates \
        curl \
        xz-utils \
        tar \
    && rm -rf /var/lib/apt/lists/*

ENV CC=aarch64-linux-gnu-gcc
ENV CXX=aarch64-linux-gnu-g++
ENV AR=aarch64-linux-gnu-ar
ENV RANLIB=aarch64-linux-gnu-ranlib
ENV STRIP=aarch64-linux-gnu-strip
ENV PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
ENV PKG_CONFIG_LIBDIR=${PREFIX}/lib/pkgconfig

# Common flags for all static builds
ENV CFLAGS="-O2 -fPIC"
ENV CXXFLAGS="-O2 -fPIC"
ENV LDFLAGS="-L${PREFIX}/lib"

RUN mkdir -p ${PREFIX}/lib ${PREFIX}/include /tmp/build

WORKDIR /tmp/build

# --------------------------------------------------------------------------
# 2. Build libev (static)
# --------------------------------------------------------------------------
RUN curl -fsSL http://dist.schmorp.de/libev/libev-4.33.tar.gz -o libev.tar.gz \
    && tar xzf libev.tar.gz \
    && cd libev-4.33 \
    && ./configure --host=${TARGET} --prefix=${PREFIX} \
       --enable-static --disable-shared \
       CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    && make -j$(nproc) \
    && make install \
    && cd /tmp/build && rm -rf libev-4.33 libev.tar.gz

# --------------------------------------------------------------------------
# 3. Build libsodium (static)
# --------------------------------------------------------------------------
RUN curl -fsSL https://github.com/jedisct1/libsodium/archive/refs/tags/1.0.19-RELEASE.tar.gz -o libsodium.tar.gz \
    && tar xzf libsodium.tar.gz \
    && cd libsodium-1.0.19-RELEASE \
    && ./autogen.sh \
    && ./configure --host=${TARGET} --prefix=${PREFIX} \
       --enable-static --disable-shared \
       CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    && make -j$(nproc) \
    && make install \
    && cd /tmp/build && rm -rf libsodium-1.0.19-RELEASE libsodium.tar.gz

# --------------------------------------------------------------------------
# 4. Build mbedTLS (static)
# --------------------------------------------------------------------------
RUN curl -fsSL https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v3.5.2.tar.gz -o mbedtls.tar.gz \
    && tar xzf mbedtls.tar.gz \
    && cd mbedtls-3.5.2 \
    && mkdir build && cd build \
    && cmake .. \
       -DCMAKE_C_COMPILER=${CC} \
       -DCMAKE_AR=${AR} \
       -DCMAKE_INSTALL_PREFIX=${PREFIX} \
       -DCMAKE_C_FLAGS="${CFLAGS}" \
       -DENABLE_SHARED=OFF \
       -DENABLE_STATIC=ON \
       -DENABLE_TESTING=OFF \
       -DENABLE_PROGRAMS=OFF \
       -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) \
    && make install \
    && cd /tmp/build && rm -rf mbedtls-3.5.2 mbedtls.tar.gz

# --------------------------------------------------------------------------
# 5. Build c-ares (static)
# --------------------------------------------------------------------------
RUN curl -fsSL https://github.com/c-ares/c-ares/archive/refs/tags/cares-1_22_1.tar.gz -o c-ares.tar.gz \
    && tar xzf c-ares.tar.gz \
    && cd c-ares-cares-1_22_1 \
    && mkdir build && cd build \
    && cmake .. \
       -DCMAKE_C_COMPILER=${CC} \
       -DCMAKE_AR=${AR} \
       -DCMAKE_INSTALL_PREFIX=${PREFIX} \
       -DCMAKE_C_FLAGS="${CFLAGS}" \
       -DBUILD_SHARED_LIBS=OFF \
       -DCARES_STATIC=ON \
       -DCARES_SHARED=OFF \
       -DCARES_BUILD_TESTS=OFF \
       -DCARES_BUILD_TOOLS=OFF \
       -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) \
    && make install \
    && cd /tmp/build && rm -rf c-ares-cares-1_22_1 c-ares.tar.gz

# --------------------------------------------------------------------------
# 6. Build PCRE2 (static)
# --------------------------------------------------------------------------
RUN curl -fsSL https://github.com/PCRE2Project/pcre2/archive/refs/tags/pcre2-10.42.tar.gz -o pcre2.tar.gz \
    && tar xzf pcre2.tar.gz \
    && cd pcre2-pcre2-10.42 \
    && mkdir build && cd build \
    && cmake .. \
       -DCMAKE_C_COMPILER=${CC} \
       -DCMAKE_AR=${AR} \
       -DCMAKE_INSTALL_PREFIX=${PREFIX} \
       -DCMAKE_C_FLAGS="${CFLAGS}" \
       -DBUILD_SHARED_LIBS=OFF \
       -DPCRE2_BUILD_PCRE2GREP=OFF \
       -DPCRE2_BUILD_TESTS=OFF \
       -DPCRE2_SUPPORT_JIT=OFF \
       -DPCRE2_BUILD_STATIC_LIB=ON \
       -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) \
    && make install \
    && cd /tmp/build && rm -rf pcre2-pcre2-10.42 pcre2.tar.gz

# --------------------------------------------------------------------------
# 7. Build shadowsocks-libev (static, cross-compiled)
# --------------------------------------------------------------------------
COPY . /tmp/repo

RUN cd /tmp/repo \
    # Verify submodules are present (they're copied as part of the repo)
    && test -d libcork/src && test -d libipset/src && test -d libbloom \
    && mkdir -p build && cd build \
    && cmake .. \
       -DCMAKE_TOOLCHAIN_FILE=/tmp/repo/docker/arm64-static/toolchain.cmake \
       -DCMAKE_BUILD_TYPE=Release \
       -DBUILD_TESTING=OFF \
       -DWITH_STATIC=ON \
       -DWITH_EMBEDDED_SRC=ON \
       -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
       -DCMAKE_REQUIRED_INCLUDES="${PREFIX}/include" \
       -DCMAKE_C_FLAGS="-O2 -g -I${PREFIX}/include -L${PREFIX}/lib" \
       -DCMAKE_EXE_LINKER_FLAGS="-static -L${PREFIX}/lib" \
       -DSODIUM_INCLUDE_DIR=${PREFIX}/include \
       -DSODIUM_LIBRARY=${PREFIX}/lib/libsodium.a \
       -DMBEDTLS_INCLUDE_DIR=${PREFIX}/include \
       -DMBEDTLS_CRYPTO_LIBRARY=${PREFIX}/lib/libmbedcrypto.a \
       -DMBEDTLS_TLS_LIBRARY=${PREFIX}/lib/libmbedtls.a \
       -DCARES_INCLUDE_DIR=${PREFIX}/include \
       -DCARES_LIBRARY=${PREFIX}/lib/libcares.a \
       -DPCRE2_INCLUDE_DIR=${PREFIX}/include \
       -DPCRE2_LIBRARY=${PREFIX}/lib/libpcre2-8.a \
       -DLIBSODIUM=${PREFIX}/lib/libsodium.a \
       -DLIBMBEDTLS=${PREFIX}/lib/libmbedtls.a \
       -DLIBMBEDCRYPTO=${PREFIX}/lib/libmbedcrypto.a \
       -DLIBEV=${PREFIX}/lib/libev.a \
       -DLIBUDNS=${PREFIX}/lib/libcares.a \
       -DLIBPCRE2=${PREFIX}/lib/libpcre2-8.a \
    && make -j$(nproc) ss-server ss-local ss-tunnel ss-redir ss-manager \
    && ${STRIP} bin/ss-server bin/ss-local bin/ss-tunnel bin/ss-redir bin/ss-manager

# --------------------------------------------------------------------------
# 8. Copy output binaries
# --------------------------------------------------------------------------
RUN mkdir -p /output \
    && cp /tmp/repo/build/bin/ss-server  /output/ \
    && cp /tmp/repo/build/bin/ss-local   /output/ \
    && cp /tmp/repo/build/bin/ss-tunnel  /output/ \
    && cp /tmp/repo/build/bin/ss-redir   /output/ \
    && cp /tmp/repo/build/bin/ss-manager /output/

CMD ["echo", "Build complete. Use: docker cp <container>:/output ./arm64-output"]
