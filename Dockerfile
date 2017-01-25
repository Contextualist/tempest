FROM alpine:latest

ENV libsodium_1_0_11="https://github.com/jedisct1/libsodium/releases/download/1.0.11/libsodium-1.0.11.tar.gz" \
    CONF_DIR="/usr/local/conf" \
    KCPTUN_DIR=/usr/local/kcp-server

RUN set -ex && \
    apk add --no-cache pcre bash openssl-dev openssh curl && \
    apk add --no-cache  --virtual TMP autoconf build-base tar libtool linux-headers pcre-dev && \
    curl -fLsS https://glare.arukascloud.io/shadowsocks/shadowsocks-libev/tar | tar xz && \
    cd shadowsocks* && \
    ./configure --disable-documentation && \
    make install && \
    cd .. && \
    rm -rf shadowsocks* && \
    mkdir /tmp/libsodium && \
    curl -LsS ${libsodium_1_0_11} | tar xz -C /tmp/libsodium --strip-components=1 && \
    cd /tmp/libsodium && \
    ./configure && \
    make -j $(awk '/processor/{i++}END{print i}' /proc/cpuinfo) && \
    make install && \
    [ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR} && \
    [ ! -d ${KCPTUN_DIR} ] && mkdir -p ${KCPTUN_DIR} && \
    sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config && \
    apk --no-cache del --virtual TMP && \
    apk --no-cache del build-base autoconf && \
    rm -rf /var/cache/apk/* ~/.cache /tmp/libsodium


ADD *.sh /
RUN chmod +x /*.sh

EXPOSE 22
EXPOSE 29900/udp
ENTRYPOINT ["/entrypoint.sh"]
