#!/bin/bash

rm -f /etc/cron.d/cron-save
ln -s /var/www/crontab /etc/cron.d/cron-save
chmod 0644 /var/www/crontab

rm -f /.env
printenv | sed 's/^\(.*\)$/export \1/g' > /.env

cron

tail -f /var/log/cron.log