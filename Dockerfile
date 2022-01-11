
ARG platform=$TARGETPLATFORM

FROM --platform=${platform} debian:bullseye

ENV DEBIAN_FRONTEND noninteractive

ARG PKG_PROXY
ARG USE_QEMU=0
ARG PIGEN_REPO
ARG PIGEN_VER

RUN set -ex \
  # set build-time proxy
  ; if [ -n "$PKG_PROXY" ]  \
  ; then echo "Acquire::http::Proxy \"$PKG_PROXY\";" >> /etc/apt/apt.conf.d/01proxybuild \
  ; fi \
  # required packages
  ; apt-get -y update \
  ; apt-get -y install --no-install-recommends \
  git vim parted quilt coreutils debootstrap zerofree zip dosfstools \
  libarchive-tools libcap2-bin rsync grep udev xz-utils curl xxd file kmod bc\
  ca-certificates qemu-utils kpartx qemu-user-static \
  # clone and export the pi-gen repo
  ; git clone ${PIGEN_REPO} /pi-gen \
  ; mkdir -p /pi-gen/work /pi-gen/deploy \
  ; cd /pi-gen \
  # ; git config advice.detachedHead false \
  ; git checkout ${PIGEN_VER} > /dev/null \
  # cleanup
  ; apt-get clean \
  ; rm /etc/apt/apt.conf.d/01proxybuild || true \
  ; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

COPY docker-entrypoint.sh /

WORKDIR /pi-gen

VOLUME [ "/pi-gen/work", "/pi-gen/deploy" ]

ENTRYPOINT [ "/bin/bash", "-c", "/docker-entrypoint.sh" ]

