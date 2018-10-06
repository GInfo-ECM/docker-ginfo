FROM ubuntu:latest
MAINTAINER pnahoum@ec-m.fr

ADD crontab /etc/cron.d/cron-save

RUN chmod 0644 /etc/cron.d/cron-save

RUN touch /var/log/cron.log

RUN apt-get update
RUN apt-get -y install cron

CMD cron && tail -f /var/log/cron.log