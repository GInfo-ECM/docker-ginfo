FROM mobtitude/vpn-pptp

RUN chmod +x /entrypoint.sh

RUN mkdir -p /etc/ppp/

ARG username
ARG password

RUN echo "$username * $password *" >> /etc/ppp/chap-secrets