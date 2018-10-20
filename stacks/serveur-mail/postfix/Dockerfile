FROM ubuntu:bionic
MAINTAINER pnahoum

# apt-get non interactif
ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get update

# Installation des packets
RUN apt-get -y install supervisor postfix sasl2-bin opendkim opendkim-tools \
&& apt-get install -y net-tools \
&& apt-get install -y iputils-ping

COPY main.conf /etc/postfix/main.conf

# Lancement
CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf