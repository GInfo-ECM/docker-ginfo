FROM wordpress:latest

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
RUN chmod 770 /var/log

# Add crons
ADD crontab /etc/cron.d/wp-cron
RUN chmod +x /etc/cron.d/wp-cron
# In wordpress : docker-entrypoint.sh is as entrypoint
# ADD cron to this file
RUN sed -i '/bash/a \cron' /usr/local/bin/docker-entrypoint.sh

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

