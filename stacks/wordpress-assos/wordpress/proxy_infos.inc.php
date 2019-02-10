<?php
define('WP_PROXY_HOST', getenv("PROXY_HOST"));
define('WP_PROXY_PORT', '3128');
define('WP_PROXY_USERNAME', getenv("PROXY_USER"));
define('WP_PROXY_PASSWORD', getenv("PROXY_PASS"));
define('WP_PROXY_BYPASS_HOSTS', 'localhost');
?>