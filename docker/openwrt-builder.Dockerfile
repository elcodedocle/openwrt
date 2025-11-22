FROM debian:trixie-slim
RUN apt update && \
    apt install -y asciidoc bash binutils bison build-essential bzip2 clang file \
    flex g++ g++-multilib gawk gcc gcc-multilib gettext git gzip help2man \
    intltool libelf-dev libncurses-dev libncurses5-dev libssl-dev \
    libthread-queue-any-perl make patch perl-modules python3-dev \
    python3-setuptools rsync swig time unzip util-linux wget xsltproc \
    zlib1g-dev && \
    apt clean && \
    useradd -ms /bin/bash openwrt
USER openwrt
RUN mkdir -p /home/openwrt/openwrt
COPY --chmod=755 entrypoint.sh /home/openwrt
ENTRYPOINT ["/home/openwrt/entrypoint.sh"]
ARG VERBOSE=false
ARG SKIP_FEEDS_UPDATE_AND_INSTALL=false
ARG MENUCONFIG=false
ARG SKIP_BUILD=false
ARG BUILD_TARGETS="defconfig download clean world"