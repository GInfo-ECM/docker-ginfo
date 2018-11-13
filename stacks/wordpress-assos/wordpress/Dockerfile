FROM wordpress:latest

# Add sudo in order to run wp-cli as the www-data user
RUN apt-get update && apt-get install -y sudo less mysql-client cron

# Add WP-CLI
RUN curl -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY wp-su.sh /bin/wp
RUN chmod +x /bin/wp-cli.phar /bin/wp

# Add crons
ADD crontab /etc/cron.d/hello-cron
RUN chmod 0644 /etc/cron.d/hello-cron
RUN touch /var/log/cron.log
# In wordpress : docker-entrypoint.sh is as entrypoint
# ADD cron to this file
RUN sed -i '/bash/a \cron' /usr/local/bin/docker-entrypoint.sh

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

