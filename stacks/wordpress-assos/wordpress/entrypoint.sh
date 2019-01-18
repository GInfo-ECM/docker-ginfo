#!/bin/bash

proxy_string="WP_PROXY_HOST"

/usr/local/bin/docker-entrypoint.sh &&

if ! grep -q $proxy_string "/var/www/html/wp-config.php"; then
  echo "include('/var/www/proxy_infos.inc.php');" >> /var/www/html/wp-config.php
fi