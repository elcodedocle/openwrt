FROM fedora:43
RUN dnf update --assumeyes && dnf --assumeyes install \
    asciidoc bash bash-completion binutils bzip2 diffutils \
    elfutils-libelf-devel file flex gawk gcc gcc-c++ gettext \
    gettext-common-devel gettext-devel gettext-envsubst gettext-libs \
    gettext-runtime git-core glibc-all-langpacks glibc-gconv-extra gzip \
    help2man intltool libxslt make ncurses-devel openssl-devel patch perl-base \
    perl-Data-Dumper perl-ExtUtils-MakeMaker perl-File-Compare perl-File-Copy \
    perl-FindBin perl-IPC-Cmd perl-JSON-PP perl-lib perl-Thread-Queue \
    perl-Time-Piece perl-Text-Iconv python3 python3-setuptools rsync swig tar \
    unzip util-linux wget which zlib-devel zlib-static && \
    useradd -ms /bin/bash openwrt
USER openwrt
RUN mkdir -p /home/openwrt/openwrt
WORKDIR /home/openwrt/openwrt
COPY --chmod=755 docker/entrypoint.sh /home/openwrt
ENTRYPOINT ["/home/openwrt/entrypoint.sh"]
ENV FORCE_FEEDS_REFRESH=false
ENV BUILD_CONFIG_FILE_PATH=""
ENV BUILD_CONFIG_FILE_URL=""
ENV MENUCONFIG=false
ENV VERBOSE=false
ENV BUILD_TARGETS="defconfig download clean world"
# MacOS: Uncomment below to build in an unmapped volume
# and avoid weird bind mapped volume mount ownership/capitalisation errors
# COPY --chmod=777 --chown=openwrt:openwrt . .