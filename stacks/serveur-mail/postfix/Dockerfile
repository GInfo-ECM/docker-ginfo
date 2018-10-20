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

# Lancement
RUN touch /var/log/syslog
CMD service postfix start && tail -f /var/log/syslog | grep postfix