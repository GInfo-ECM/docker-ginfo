#!/bin/bash

if ! grep -q "WP_PROXY_HOST" "/usr/src/wordpress/wp-config-sample.php"; then
  echo "require_once(ABSPATH . '/var/www/proxy_infos.inc.php');" >> /usr/src/wordpress/wp-config-sample.php
fi