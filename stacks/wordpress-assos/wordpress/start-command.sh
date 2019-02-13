#!/bin/bash
touch ${APACHE_LOG_DIR}/access.log &&
touch ${APACHE_LOG_DIR}/error.log &&
tail -f ${APACHE_LOG_DIR}/access.log &
tail -f ${APACHE_LOG_DIR}/error.log &
apache2-foreground