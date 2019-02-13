FROM debian:stretch
MAINTAINER pnahoum@ec-m.fr

#Install utilities
RUN apt-get update \
 && apt-get install -y apache2 \
 && apt-get install -y wget \
 && apt-get install -y nano \
 && apt-get install -y iputils-ping \
 && apt-get install -y net-tools \
 && apt-get install -y traceroute \
 && apt-get install -y zip

#Gestion clés ssh
RUN mkdir /var/www/.ssh
RUN ln -s /var/www/.ssh /root/.ssh

#Install npm and node.js
RUN apt-get -y install gnupg && apt-get -y install gnupg1 && apt-get -y install gnupg2
RUN apt-get -y install curl software-properties-common
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

#Dossier par défaut de apache et configuration du reverse proxy
ENV APACHE_DOCUMENT_ROOT /var/www/html
ENV APACHE_LOG_DIR /var/www/logs


RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

RUN echo "ServerName localhost" >> /etc/apache2/conf-available/servername.conf
RUN a2enconf servername.conf

#Gestion du reverse proxy
COPY remoteip.conf /etc/apache2/conf-available/remoteip.conf
RUN a2enconf remoteip.conf
RUN a2enmod remoteip
RUN sed -i 's/%h/%a/g' /etc/apache2/apache2.conf

#Gestion du Mod Security
RUN apt-get install -y libapache2-modsecurity \
 && mv /etc/modsecurity/modsecurity.conf-recommended  /var/www/modsecurity.conf \
 && ln -s /var/www/modsecurity.conf /etc/modsecurity/modsecurity.conf \
 && sed -i 's/DetectionOnly/On/g' /var/www/modsecurity.conf

#Gestion de l'heure
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY timezone.ini /usr/local/etc/php/conf.d/timezone.ini

#Gestion de point d'entrées
COPY startup.sh /var/www/startup.sh
RUN chmod +x /var/www/startup.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#Gestion des logs
RUN mkdir -p ${APACHE_LOG_DIR}/
RUN mkdir -p ${APACHE_DOCUMENT_ROOT}/
RUN touch ${APACHE_LOG_DIR}/access.log
RUN touch ${APACHE_LOG_DIR}/error.log
RUN chown -R www-data:www-data ${APACHE_LOG_DIR}


#Gestion du launcher
COPY apache2-foreground /usr/bin/
RUN chmod +x /usr/bin/apache2-foreground

CMD /entrypoint.sh

EXPOSE 80