#!/bin/bash

rm -f /etc/cron.d/cron-save
ln -s /var/www/crontab /etc/cron.d/cron-save
chmod 0644 /var/www/crontab

rm -f /etc/environment
printenv | sed 's/^\(.*\)$/export \1/g' > /etc/environment

cron

tail -f /var/log/cron.log