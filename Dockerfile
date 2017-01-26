FROM alpine:latest

ENV CONF_DIR="/usr/local/conf" \
    KCPTUN_DIR=/usr/local/kcp-server

RUN set -ex && \
    apk add --no-cache bash \
                       curl \
                       openssh \
                       openssl-dev \
                       libcrypto1.0 \
                       libev \
                       libsodium \
                       pcre \
                       tar \
                       udns && \
    apk add --no-cache --virtual TMP autoconf \
                                     automake \
                                     build-base \
                                     gettext-dev \
                                     libev-dev \
                                     libsodium-dev \
                                     libtool \
                                     linux-headers \
                                     pcre-dev \
                                     udns-dev && \
    curl -fLsS https://glare.arukascloud.io/shadowsocks/shadowsocks-libev/gz | tar xz && \
    cd shadowsocks* && \
    curl -sSL https://github.com/shadowsocks/ipset/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libipset && \
    curl -sSL https://github.com/shadowsocks/libcork/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libcork && \
    ./autogen.sh && \
    ./configure --disable-documentation && \
    make install && \
    cd .. && \
    rm -rf shadowsocks* && \
    [ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR} && \
    [ ! -d ${KCPTUN_DIR} ] && mkdir -p ${KCPTUN_DIR} && \
    sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config && \
    apk --no-cache del TMP && \
    rm -rf /var/cache/apk/* ~/.cache


ADD *.sh /
RUN chmod +x /*.sh

EXPOSE 22
EXPOSE 29900/udp
ENTRYPOINT ["/entrypoint.sh"]
