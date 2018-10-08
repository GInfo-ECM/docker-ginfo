#!/usr/bin/env bash
htpasswd -b -c /phpmyadmin/.htpasswd ${DB_USER} ${DB_PASSWORD}
apache2-foreground