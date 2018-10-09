#!/bin/bash
/var/www/startup.sh &
htpasswd -b -c /phpmyadmin/.htpasswd ${DB_USER} ${DB_PASSWORD}
apache2-foreground