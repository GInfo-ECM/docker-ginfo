FROM wordpress:latest

# Add sudo in order to run wp-cli as the www-data user
RUN apt-get update && apt-get install -y sudo less mysql-client cron jq

# Add WP-CLI
RUN curl -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY wp-su.sh /bin/wp
RUN chmod +x /bin/wp-cli.phar /bin/wp

# Add updates (with file removal)
COPY update.sh /var/www/html/wp-update
COPY themes-remove.sh /var/www/html/wp-theme-remove
COPY plugins-remove.sh /var/www/html/wp-plugin-remove
RUN chmod +x /var/www/html/wp-update
RUN chmod +x /var/www/html/wp-theme-remove
RUN chmod +x /var/www/html/wp-plugin-remove

# Add crons
ADD crontab /etc/cron.d/wp-cron
RUN chmod +x /etc/cron.d/wp-cron
# In wordpress : docker-entrypoint.sh is as entrypoint
# ADD cron to this file
RUN sed -i '/bash/a \cron' /usr/local/bin/docker-entrypoint.sh

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

