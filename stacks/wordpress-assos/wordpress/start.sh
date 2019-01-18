#!/bin/bash

sleep 10
if ! grep -q "WP_PROXY_HOST" "/var/www/html/wp-config.php"; then
  echo "include('/var/www/proxy_infos.inc.php');" >> /var/www/html/wp-config.php
fi