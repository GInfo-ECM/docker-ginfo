#!/bin/sh

wp cli update >> /var/log/wpcliupdate.log 2>&1

wp core update --path="/var/www/html" >> /var/log/wpupdate.log 2>&1

wp core update-db --path="/var/www/html" >> /var/log/wpupdatedb.log 2>&1
