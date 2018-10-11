FROM mobtitude/vpn-pptp

RUN chmod +x /entrypoint.sh

RUN mkdir -p /etc/ppp/

ARG username
ARG password

RUN rm -f /etc/ppp/chap-secrets

RUN echo "$username * $password *" >> /etc/ppp/chap-secrets

ENTRYPOINT ["sh","/entrypoint.sh"]