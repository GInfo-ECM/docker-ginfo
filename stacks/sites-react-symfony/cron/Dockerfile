FROM ubuntu:latest
MAINTAINER pnahoum@ec-m.fr

ENV DEBIAN_FRONTEND=noninteractive
ENV UBUNTU_FRONTEND=noninteractive

COPY crontab /saves/crontab

RUN touch /var/log/cron.log

COPY backup.sh /etc/backup.sh
RUN chmod +x /etc/backup.sh

RUN apt update \
&& apt -y install cron \
&& apt -y install nano \
&& apt -y install mysql-client \
&& apt -y install tzdata \
&& apt -y install corkscrew \
&& apt -y install ssh

#Gestion de l'heure
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh