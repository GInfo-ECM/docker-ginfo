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
	&& pecl install apcu \
	&& docker-php-ext-enable apcu \
    && a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_http \
    && a2enmod proxy_balancer \
    && a2enmod lbmethod_byrequests \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer

#Install utilities
RUN apt-get update \
 && apt-get install -y wget \
 && apt-get install -y nano \
 && apt-get install -y iputils-ping \
 && apt-get install -y net-tools \
 && apt-get install -y traceroute \
 && apt-get install -y zip

#Installation de phpmyadmin et sécurisation
RUN mkdir /phpmyadmin \
 && curl https://files.phpmyadmin.net/phpMyAdmin/4.8.3/phpMyAdmin-4.8.3-all-languages.tar.gz | tar xvz -C /phpmyadmin --strip-components=1 \
 && cp /phpmyadmin/config.sample.inc.php /phpmyadmin/config.inc.php \
 && sed -i 's/localhost/db/g' /phpmyadmin/config.inc.php \
 && touch /phpmyadmin/.htpasswd

COPY phpmyadmin/.htaccess /phpmyadmin/.htaccess

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

RUN echo "ServerName localhost" >> /etc/apache2/conf-available/servername.conf
RUN a2enconf servername.conf

COPY remoteip.conf /etc/apache2/conf-available/remoteip.conf
RUN a2enconf remoteip.conf
RUN a2enmod remoteip
RUN sed -i 's/%h/%a/g' /etc/apache2/apache2.conf

#Gestion de l'heure
RUN apt install -y tzdata
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Gestion de point d'entrée
COPY startup.sh /var/www/startup.sh
RUN chmod +x /var/www/startup.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


CMD /entrypoint.sh