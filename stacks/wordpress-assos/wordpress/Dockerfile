FROM wordpress:5.0.3-php7.2

# Add sudo in order to run wp-cli as the www-data user
RUN apt-get update && apt-get install -y sudo less mysql-client cron jq

# Add WP-CLI
RUN curl -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY wp-su.sh /bin/wp
RUN chmod +x /bin/wp-cli.phar /bin/wp

# Add updates (with file removal)
COPY update.sh /usr/lib/wp-update
COPY themes-remove.sh /usr/lib/wp-theme-remove
COPY plugins-remove.sh /usr/lib/wp-plugin-remove
RUN chmod +x /usr/lib/wp-update
RUN chmod +x /usr/lib/wp-theme-remove
RUN chmod +x /usr/lib/wp-plugin-remove
RUN apt -y update
RUN apt -y install nano
RUN apt -y install iputils-ping

# Add crons
ADD crontab /etc/cron.d/wp-cron
RUN chmod +x /etc/cron.d/wp-cron
# In wordpress : docker-entrypoint.sh is as entrypoint
# ADD cron to this file
RUN sed -i '/bash/a \cron' /usr/local/bin/docker-entrypoint.sh

#Gestion du reverse proxy
COPY remoteip.conf /etc/apache2/conf-available/remoteip.conf
RUN a2enconf remoteip.conf
RUN a2enmod remoteip
RUN sed -i 's/%h/%a/g' /etc/apache2/apache2.conf

#Gestion du proxy
COPY proxy_infos.inc.php /var/www/proxy_infos.inc.php
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
RUN start.sh

#Servername setup apache
RUN echo "ServerName localhost" >> /etc/apache2/conf-available/servername.conf
RUN a2enconf servername.conf

#Gestion du Mod Security
COPY modsecurity_rules /var/www/misc/modsecurity.conf
RUN apt-get install -y libapache2-modsecurity \
 && ln -s /var/www/misc/modsecurity.conf /etc/modsecurity/modsecurity.conf

#Gestion des logs
ENV APACHE_LOG_DIR /var/www/misc/logs
RUN mkdir -p /var/www/misc/logs

#Gestion de l'heure
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY timezone.ini /usr/local/etc/php/conf.d/timezone.ini

#Gestion de la taille des uploads
COPY uploads.ini /usr/local/etc/php/conf.d/

#Gestion de l'envoi de mails
RUN apt-get install -y ssmtp && \
  apt-get clean && \
  sed -i 's/mailhub=mail/mailhub=postfix:25/g' /etc/ssmtp/ssmtp.conf && \
  sed -i 's/#rewriteDomain=/rewriteDomain=centrale-marseille.fr/g' /etc/ssmtp/ssmtp.conf && \
  chfn -f "WordPress - GInfo Centrale Marseille" www-data && \
  echo "www-data:no-reply@centrale-marseille.fr:postfix:25" >> /etc/ssmtp/revaliases && \
  echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

#Gestion de l'affichage des logs dans la console docker
RUN sed -i.bck '$s/$/ \&\ntail -f ${APACHE_LOG_DIR}\/access.log \&\ntail -f ${APACHE_LOG_DIR}\/error.log/' /usr/local/bin/docker-entrypoint.sh

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

