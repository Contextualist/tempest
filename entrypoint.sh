#!/bin/bash
. def.sh

cat > ${SS_CONF}<<-EOF
{
    "server":"${SS_SERVER_ADDR}",
    "server_port":${SS_SERVER_PORT},
    "password":"${SS_PASSWORD}",
    "timeout":${SS_TIMEOUT},
    "method":"${SS_METHOD}",
    "auth":${SS_ONETIME_AUTH},
    "fast_open":${SS_FAST_OPEN},
    "nameserver":"${SS_DNS_ADDR}",
    "mode":"${SS_MODE}"
}
EOF

echo "Starting Shadowsocks-libev..."
nohup ss-server -c ${SS_CONF} >/dev/null 2>&1 &
sleep 0.3
echo "ss-server (pid `pidof ss-server`)is running."
netstat -ntlup | grep ss-server

kupdate

if $DEBUG ; then
    envar "KCPTUN_SNMPLOG=${KCPTUN_LOG}"
    echo "root:${ROOT_PSWD}" | chpasswd
    ssh-keygen -A
    exec /usr/sbin/sshd -D -e
else
    kstart
fi
