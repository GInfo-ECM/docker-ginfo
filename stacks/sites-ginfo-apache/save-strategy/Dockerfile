FROM ubuntu:latest
MAINTAINER pnahoum@ec-m.fr

ENV DEBIAN_FRONTEND=noninteractive
ENV UBUNTU_FRONTEND=noninteractive

COPY crontab /site-to-save/crontab

RUN touch /var/log/cron.log

COPY backup.sh /etc/backup.sh
RUN chmod +x /etc/backup.sh

RUN apt-get update
RUN apt-get -y install cron && apt-get -y install nano && apt-get -y install mysql-client
RUN apt-get install -y tzdata

#Gestion de l'heure
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh