
ARG platform=$TARGETPLATFORM

FROM --platform=${platform} mindspy/pigen:latest as pre-bootstrap

ARG RELEASE=bullseye
ARG PKG_PROXY

RUN set -ex \
    # set build-time proxy
    ; apt_conf=/etc/apt/apt.conf.d/01tmpproxy-$(shuf  -i 1000-9999 -n1) \
    ; if [ -n "$PKG_PROXY" ] \
    ; then echo "Acquire::http::Proxy \"$PKG_PROXY\";" > $apt_conf \
    ; export http_proxy=${PKG_PROXY}  \
    ; fi \
    # prepare bootstrap 
    ; mkdir /rootfs \
    ; ARCH="$(dpkg --print-architecture)" \
    ; case "$ARCH" in \
    armhf) REPO=http://raspbian.raspberrypi.org/raspbian/ ; ARGS="--keyring /pi-gen/raspberrypi.gpg" ;; \
    arm64) REPO=http://deb.debian.org/debian/ ;; \
    *) echo "Unexpected arch: $ARCH"; exit 1 ;; \
    esac \
    ; debootstrap --foreign --arch $ARCH --components main,contrib,non-free --variant=minbase \
    --exclude=info,e2fsprogs,libext2fs2,libss2,logsave,gcc-7-base,gcc-8-base,gcc-9-base,tzdata \
    $ARGS $RELEASE /rootfs $REPO \ 
    ; env --unset http_proxy || true \
    ; rm $apt_conf || true 

FROM --platform=${platform} scratch as bootstrap

COPY --from=pre-bootstrap /rootfs /
COPY files /pi-gen

ARG RELEASE=bullseye 
ARG FIRST_USER_NAME=pi 
ARG PKG_PROXY

RUN set -ex \
    ; export DEBIAN_FRONTEND=noninteractive \
    # set build-time proxy
    ; apt_conf=/etc/apt/apt.conf.d/01tmpproxy-$(shuf  -i 1000-9999 -n1) \
    ; if [ -n "$PKG_PROXY" ] \
    ; then echo "Acquire::http::Proxy \"$PKG_PROXY\";" > $apt_conf \
    ; export http_proxy=${PKG_PROXY}  \
    ; fi \
    # continue with bootstraping
    ; /debootstrap/debootstrap --second-stage \
    # install raspios repositories and rpi packages
    ; ARCH="$(dpkg --print-architecture)" \
    ; install -m 644 -T /pi-gen/sources-${ARCH}.list /etc/apt/sources.list \
    ; install -m 644 -T /pi-gen/raspi-${ARCH}.list /etc/apt/sources.list.d/raspi.list \
    ; install -m 644 /pi-gen/raspbian.gpg /usr/share/keyrings/ \
    ; install -m 644 /pi-gen/raspberrypi.gpg /usr/share/keyrings/ \
    ; sed -i "s/RELEASE/${RELEASE}/g" /etc/apt/sources.list \
    ; sed -i "s/RELEASE/${RELEASE}/g" /etc/apt/sources.list.d/raspi.list \
    ; apt-get update --yes \
    ; apt-get dist-upgrade --yes \
    ; apt-get install --yes --no-install-recommends libraspberrypi-bin libraspberrypi0 \
    ; apt-get install --yes --no-install-recommends netbase \
    # add user and groups
    ; if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1 \
    ; then adduser --disabled-password --gecos "" ${FIRST_USER_NAME} \
    ; fi \
    ; for g in input spi i2c gpio \
    ; do groupadd -f -r $g \
    ; done \
    ; for g in adm dialout cdrom audio users sudo video games plugdev input gpio spi i2c \
    ; do adduser $FIRST_USER_NAME $g \
    ; done \
    # cleanup
    ; apt-get clean \
    ; env --unset http_proxy DEBIAN_FRONTEND || true \
    ; rm $apt_conf || true \
    ; rm -fr /tmp/* /var/cache/* /var/lib/apt/lists/* /var/tmp/* /boot/* /pi-gen 


FROM --platform=${platform} scratch as final
# create clean image 
COPY --from=bootstrap / /
