#!/bin/sh

wp core update >> /var/log/wpupdate.log 2>&1

wp core update-db >> /var/log/wpupdatedb.log 2>&1
