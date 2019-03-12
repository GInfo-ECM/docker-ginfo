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
COPY start.sh /start.sh

RUN echo "fast unix - - n - - smtp" >> /etc/postfix/master.cf
ARG relay
ARG monitoring_email
RUN sed -i 's/relais.adresse.ltd/'$relay'/g' /etc/postfix/main.cf
RUN sed -i 's/relais.adresse.ltd/'$relay'/g' /etc/postfix/transport
RUN sed -i 's/monitoring@domain.mail.ltd/'$monitoring_email'/g' /start.sh

#Gestion de l'heure
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN postmap /etc/postfix/transport
RUN chmod +x /start.sh

# Lancement
RUN touch /var/log/syslog
CMD /start.sh