#!/bin/sh

############### Printing in a log file
logfile=/var/log/wpupdate-$(date +\%Y\%m\%d).log
exec > $logfile 2>&1

##### No need to update wp-cli
# wp cli update >> /var/log/wpcliupdate.log 2>&1

d=$(date)
echo "Tâches de routines du "$d

cd /var/www/html

echo "\n------ Updating Core ------"
wp core update --path="/var/www/html"


echo "\n------ Db Core update ------"
wp core update-db --path="/var/www/html"


echo "\n------ Deprecated themes removal ------"
/usr/lib/wp-theme-remove


echo "\n------ Deprecated plugins removal ------"
/usr/lib/wp-plugin-remove


echo "\n------ Themes update ------"
wp theme list
wp theme update --all


echo "\n------ Plugins update ------"
wp plugin list
wp plugin update --all

