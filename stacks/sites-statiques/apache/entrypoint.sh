#!/bin/bash
/var/www/startup.sh &&
tail -f ${APACHE_LOG_DIR}/access.log &
tail -f ${APACHE_LOG_DIR}/error.log &
httpd-foreground