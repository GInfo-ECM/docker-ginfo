FROM php:7.2.9-apache-stretch
MAINTAINER pnahoum@ec-m.fr

RUN buildDeps=" \
        default-libmysqlclient-dev \
        libbz2-dev \
        libmemcached-dev \
        libsasl2-dev \
    " \
    runtimeDeps=" \
        curl \
        git \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libmemcachedutil2 \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
    && docker-php-ext-install bcmath bz2 calendar iconv intl mbstring mysqli opcache pdo_mysql pdo_pgsql pgsql soap zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && docker-php-ext-install exif \
    && pecl install memcached redis \
    && docker-php-ext-enable memcached.so redis.so \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
	&& pecl install apcu \
	&& docker-php-ext-enable apcu \
    && a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_http \
    && a2enmod proxy_balancer \
    && a2enmod lbmethod_byrequests

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer

#Install wget and ping
RUN apt-get update && apt-get install -y wget && apt-get install -y nano && apt-get install -y iputils-ping

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

RUN echo "ServerName localhost" >> /etc/apache2/conf-available/servername.conf
RUN a2enconf servername.conf

RUN echo "RemoteIPHeader X-Forwarded-For" >> /etc/apache2/conf-available/remoteip.conf
RUN echo "RemoteIPInternalProxy 127.0.0.1 \${TRUSTED_PROXIES}" >> /etc/apache2/conf-available/remoteip.conf
RUN a2enconf remoteip.conf
RUN a2enmod remoteip
RUN sed -i 's/%h/%a/g' /etc/apache2/apache2.conf

#Stratégie de sauvegarde
RUN touch /var/log/cron.log
COPY cron /etc/cron.d/cron-sauvegarde
RUN chmod 0644 /etc/cron.d/cron-sauvegarde
RUN service cron start