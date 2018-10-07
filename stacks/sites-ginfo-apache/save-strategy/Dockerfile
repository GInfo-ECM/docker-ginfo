FROM ubuntu:latest
MAINTAINER pnahoum@ec-m.fr

ADD crontab /etc/cron.d/cron-save

RUN chmod 0644 /etc/cron.d/cron-save

RUN touch /var/log/cron.log

COPY backup.sh /etc/backup.sh
RUN chmod +x /etc/backup.sh

RUN apt-get update
RUN apt-get -y install cron && apt-get -y install nano && apt-get -y install mysql-client

CMD cron && tail -f /var/log/cron.log