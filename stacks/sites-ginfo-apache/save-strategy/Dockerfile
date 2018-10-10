FROM ubuntu:latest
MAINTAINER pnahoum@ec-m.fr

COPY crontab /var/www/crontab

RUN touch /var/log/cron.log

COPY backup.sh /etc/backup.sh
RUN chmod +x /etc/backup.sh

RUN apt-get update
RUN apt-get -y install cron && apt-get -y install nano && apt-get -y install mysql-client

#Gestion de l'heure
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh