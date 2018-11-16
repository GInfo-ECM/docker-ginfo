#!/bin/bash

wp core update >> /var/log/wpupdate.log
wp core update-db >> /val/log/wpupdatedb.log
