FROM mobtitude/vpn-pptp

ADD login.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN mkdir -p /etc/ppp/

ENTRYPOINT ["sh","/entrypoint.sh"]