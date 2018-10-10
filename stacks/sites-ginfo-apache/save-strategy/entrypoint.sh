#!/bin/bash

rm -f /etc/cron.d/cron-save
ln -s /saves/crontab /etc/cron.d/cron-save
chmod 0644 /saves/crontab

rm -f /etc/environment
printenv | sed 's/^\(.*\)$/export \1/g' > /etc/environment

cron

tail -f /var/log/cron.log