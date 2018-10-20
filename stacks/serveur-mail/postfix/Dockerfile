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
&& apt-get install -y nano

COPY main.cf /etc/postfix/main.cf
COPY transport /etc/postfix/transport
COPY allowed_senders /etc/postfix/allowed_senders

RUN echo "fast unix - - n - - smtp -o smtp_fallback_relay=" >> /etc/postfix/master.cf
ARG relay
RUN sed -i 's/relais.adresse.ltd/'$relay'/g' /etc/postfix/main.cf
RUN sed -i 's/relais.adresse.ltd/'$relay'/g' /etc/postfix/transport
RUN postmap /etc/postfix/transport

# Lancement
RUN touch /var/log/syslog
CMD service postfix start && tail -f /var/log/syslog | grep postfix