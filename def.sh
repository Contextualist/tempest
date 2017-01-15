#!/bin/bash

set -e
DEBUG=${DEBUG:-false}
ROOT_PSWD=${ROOT_PSWD:-root}
KCPTUN_DIR=/usr/local/kcp-server
KCPTUN_CONF="/usr/local/conf/kcptun_config.json"
KCPTUN_LOG="/var/log/kcptun_snmp.log"
SS_CONF="/usr/local/conf/ss_config.json"
# ======= SS CONFIG ======
SS_SERVER_ADDR=${SS_SERVER_ADDR:-127.0.0.1}
SS_SERVER_PORT=${SS_SERVER_PORT:-8388}
SS_PASSWORD=${SS_PASSWORD:-password}
SS_METHOD=${SS_METHOD:-aes-256-cfb}
SS_TIMEOUT=${SS_TIMEOUT:-60}
SS_ONETIME_AUTH=${SS_ONETIME_AUTH:-true}
SS_FAST_OPEN=${SS_FAST_OPEN:-true}
SS_DNS_ADDR=${SS_DNS_ADDR:-8.8.8.8}
SS_MODE=${SS_MODE:-tcp_and_udp}
# ======= KCPTUN CONFIG ======
KCPTUN_LISTEN=${KCPTUN_LISTEN:-29900}
KCPTUN_KEY=${KCPTUN_KEY:-password}
KCPTUN_CRYPT=${KCPTUN_CRYPT:-aes-128}
KCPTUN_MODE=${KCPTUN_MODE:-fast2}
KCPTUN_MTU=${KCPTUN_MTU:-1350}
KCPTUN_SNDWND=${KCPTUN_SNDWND:-1024}
KCPTUN_RCVWND=${KCPTUN_RCVWND:-1024}
KCPTUN_DATASHARD=${KCPTUN_DATASHARD:-10}
KCPTUN_PARITYSHARD=${KCPTUN_PARITYSHARD:-3}
KCPTUN_DSCP=${KCPTUN_DSCP:-0}
KCPTUN_NOCOMP=${KCPTUN_NOCOMP:-false}
KCPTUN_ACKNODELAY=${KCPTUN_ACKNODELAY:-false}
KCPTUN_NODELAY=${KCPTUN_NODELAY:-0}
KCPTUN_INTERVAL=${KCPTUN_INTERVAL:-40}
KCPTUN_RESEND=${KCPTUN_RESEND:-0}
KCPTUN_NC=${KCPTUN_NC:-0}
KCPTUN_SOCKBUF=${KCPTUN_SOCKBUF:-4194304}
KCPTUN_KEEPALIVE=${KCPTUN_KEEPALIVE:-10}
KCPTUN_SNMPLOG=${KCPTUN_SNMPLOG:-}

function kupdate {
    curl -fL https://glare.arukascloud.io/xtaci/kcptun/linux-amd64 | tar xz -C ${KCPTUN_DIR}/
    rm -f ${KCPTUN_DIR}/kcp-server
    mv ${KCPTUN_DIR}/server_linux_amd64 ${KCPTUN_DIR}/kcp-server
    rm -f ${KCPTUN_DIR}/client_linux_amd64
    chown root:root ${KCPTUN_DIR}/*
    chmod 755 ${KCPTUN_DIR}/*
}

function kstart {
    rm -f ${KCPTUN_LOG}
    rm -f ${KCPTUN_CONF}
    cat > ${KCPTUN_CONF}<<-EOF
    {
        "listen": ":${KCPTUN_LISTEN}",
        "target": "127.0.0.1:${SS_SERVER_PORT}",
        "key": "${KCPTUN_KEY}",
        "crypt": "${KCPTUN_CRYPT}",
        "mode": "${KCPTUN_MODE}",
        "mtu": ${KCPTUN_MTU},
        "sndwnd": ${KCPTUN_SNDWND},
        "rcvwnd": ${KCPTUN_RCVWND},
        "datashard": ${KCPTUN_DATASHARD},
        "parityshard": ${KCPTUN_PARITYSHARD},
        "dscp": ${KCPTUN_DSCP},
        "nocomp": ${KCPTUN_NOCOMP},
        "acknodelay":${KCPTUN_ACKNODELAY},
        "nodelay":${KCPTUN_NODELAY},
        "interval":${KCPTUN_INTERVAL},
        "resend":${KCPTUN_RESEND},
        "nc":${KCPTUN_NC},
        "sockbuf":${KCPTUN_SOCKBUF},
        "keepalive":${KCPTUN_KEEPALIVE},
        "snmplog":"${KCPTUN_SNMPLOG}"
    }
EOF
    cat ${KCPTUN_CONF}
    echo "Starting Kcptun for Shadowsocks-libev..."
    exec "kcp-server" -c ${KCPTUN_CONF}
}

function kstop {
    kill `pidof kcp-server`
    cat ${KCPTUN_LOG}
}

function envar {
    echo $1 >> def.sh
    eval $1
}
