FROM cndocker/kcptun-socks5-ss-server:latest

RUN apk --update add openssh \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && rm -rf /var/cache/apk/*

WORKDIR /scripts
ADD *.sh ./
RUN chmod +x ./*.sh

EXPOSE 22
EXPOSE 34567/udp
ENTRYPOINT ["entrypoint.sh"]
