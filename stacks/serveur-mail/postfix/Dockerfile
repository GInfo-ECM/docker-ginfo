FROM ubuntu:bionic
MAINTAINER pnahoum

# apt-get non interactif
ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get update

# Installation des packets
RUN apt-get -y install supervisor postfix sasl2-bin opendkim opendkim-tools \
&& apt-get install -y net-tools \
&& apt-get install -y iputils-ping \
&& apt-get install -y nano \
&& apt-get install -y mailutils

COPY main.cf /etc/postfix/main.cf
COPY transport /etc/postfix/transport
COPY allowed_senders /etc/postfix/allowed_senders
COPY start.sh /start.sh

RUN echo "fast unix - - n - - smtp -o smtp_fallback_relay=" >> /etc/postfix/master.cf
ARG relay
ARG monitoring_email
RUN sed -i 's/relais.adresse.ltd/'$relay'/g' /etc/postfix/main.cf
RUN sed -i 's/relais.adresse.ltd/'$relay'/g' /etc/postfix/transport
RUN sed -i 's/monitoring@domain.mail.ltd/'$monitoring_email'/g' /start.sh

RUN postmap /etc/postfix/transport
RUN postmap /etc/postfix/allowed_senders
RUN chmod+x /start.sh

# Lancement
RUN touch /var/log/syslog
CMD /start.sh