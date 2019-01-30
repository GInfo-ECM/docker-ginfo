#!/bin/bash
/var/www/startup.sh && /usr/bin/apache2-foreground
#tail -f ${APACHE_LOG_DIR}/access.log &
#tail -f ${APACHE_LOG_DIR}/error.log &