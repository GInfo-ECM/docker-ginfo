FROM php:8.2-cli

RUN apt-get update && apt-get install -y cron

ADD crontab /etc/cron.d/nextcloud-maintenance

RUN chmod 0644 /etc/cron.d/nextcloud-maintenance

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod 0755 /usr/local/bin/install-php-extensions

RUN install-php-extensions gd zip pdo_mysql ldap smbclient ftp imap bcmath gmp

RUN crontab -u www-data /etc/cron.d/nextcloud-maintenance

CMD ["cron", "-f"]
