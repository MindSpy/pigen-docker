
ARG platform=$TARGETPLATFORM
ARG RELEASE=bullseye

FROM --platform=${platform} debian:${RELEASE}

ENV DEBIAN_FRONTEND noninteractive

ARG PKG_PROXY
ARG PIGEN_REPO
ARG PIGEN_VER

RUN set -ex \
  # set build-time proxy
  ; apt_conf=/etc/apt/apt.conf.d/01tmpproxy-$(shuf  -i 1000-9999 -n1) \
  ; test -n "$PKG_PROXY" && echo "Acquire::http::Proxy \"$PKG_PROXY\";" > $apt_conf \
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
  ; rm $apt_conf || true \
  ; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

COPY docker-entrypoint.sh /

WORKDIR /pi-gen

VOLUME [ "/pi-gen/work", "/pi-gen/deploy" ]

ENTRYPOINT [ "/bin/bash", "-c", "/docker-entrypoint.sh" ]

