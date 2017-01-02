FROM alpine:latest

ENV SS_2_5_6=https://github.com/shadowsocks/shadowsocks-libev/archive/v2.5.6.tar.gz \
    SS_DIR=shadowsocks-libev-2.5.6 \
    libsodium_1_0_11="https://github.com/jedisct1/libsodium/releases/download/1.0.11/libsodium-1.0.11.tar.gz" \
    oniguruma=https://github.com/kkos/oniguruma/releases/download/v5.9.6/onig-5.9.6.tar.gz \
    jq_1_5=https://github.com/stedolan/jq/releases/download/jq-1.5/jq-1.5.tar.gz \
    CONF_DIR="/usr/local/conf" \
    kcptun_latest=https://api.github.com/repos/xtaci/kcptun/releases/latest \
    KCPTUN_DIR=/usr/local/kcp-server

RUN set -ex && \
    apk add --no-cache pcre bash openssh curl && \
    apk add --no-cache  --virtual TMP autoconf build-base wget tar libtool linux-headers openssl-dev pcre-dev && \
    curl -sSL $SS_2_5_6 | tar xz && \
    cd $SS_DIR && \
    ./configure --disable-documentation && \
    make install && \
    cd .. && \
    rm -rf $SS_DIR && \
    mkdir /tmp/libsodium && \
    curl -Lk ${libsodium_1_0_11}|tar xz -C /tmp/libsodium --strip-components=1 && \
    cd /tmp/libsodium && \
    ./configure && \
    make -j $(awk '/processor/{i++}END{print i}' /proc/cpuinfo) && \
    make install && \
    curl -Lk ${oniguruma} | tar xz -C /tmp/ && \
    cd /tmp/onig-5.9.6 && \
    ./configure --enable-static --disable-shared --prefix="/usr" && \
    make && \
    make install && \
    curl -Lk ${jq_1_5} | tar xz -C /tmp/ && \
    cd /tmp/jq-1.5 && \
    ./configure --enable-static --disable-shared --prefix="/usr" CFLAGS="-I/usr/include" LDFLAGS="--static -L/usr/lib -L/usr/include" && \
    make && \
    make install && \
    [ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR} && \
    [ ! -d ${KCPTUN_DIR} ] && mkdir -p ${KCPTUN_DIR} && cd ${KCPTUN_DIR} && \
    kcptun_latest_download=`curl -s ${kcptun_latest} | jq -r ".assets[] | select(.name | test(\"linux-amd64\"; \"\")) | .browser_download_url"` && \
    curl -Lk ${kcptun_latest_download} | tar xz -C ${KCPTUN_DIR}/ && \
    mv ${KCPTUN_DIR}/server_linux_amd64 ${KCPTUN_DIR}/kcp-server && \
    rm -f ${KCPTUN_DIR}/client_linux_amd64 && \
    chown root:root ${KCPTUN_DIR}/* && \
    chmod 755 ${KCPTUN_DIR}/* && \
    ln -s ${KCPTUN_DIR}/* /bin/ && \
    sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config && \
    apk --no-cache del --virtual TMP && \
    apk --no-cache del build-base autoconf && \
    rm -rf /var/cache/apk/* ~/.cache /tmp/libsodium /tmp/onig-5.9.6 /tmp/jq-1.5


ADD *.sh /
RUN chmod +x /*.sh

EXPOSE 22
EXPOSE 29900/udp
ENTRYPOINT ["/entrypoint.sh"]
