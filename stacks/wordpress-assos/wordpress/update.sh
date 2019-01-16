#!/bin/sh

##### No need to update wp-cli
# wp cli update >> /var/log/wpcliupdate.log 2>&1

$d=date
echo "Tâches de routines du "$d


echo "\n------ Updating Core ------"
wp core update --path="/var/www/html"


echo "\n------ Db Core update ------"
wp core update-db --path="/var/www/html"


echo "\n------ Plugins update ------"
wp plugin list
wp plugin update --all


echo "\n------ Themes update ------"
wp theme list
wp theme update --all
