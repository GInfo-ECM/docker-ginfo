#!/bin/bash

################
# Configuration
################

# Server Name
server_name="localhost"

# Backup path
backup_path="/saves/backups"

# Script log file
log_file="/saves/backups/backup.log"

# Files to backup (Multi value)
backup_files_enable="no"
backup_files="/root/.bash_history /etc/passwd"

# Directories to backup (Multi value)
backup_dir_enable="yes"
backup_directories="/site-to-save"

# Upload to FTP server (Using curl command)
ftp_enable="no"
ftp_server="1.2.3.4"
ftp_path="/backups"
ftp_username=""
ftp_password=""

# Send an email the result of the backup process
# You should have sendmail or postfix installed
send_email="no"
email_to="test@gmail.com"

# Full MySQL dump (All Databases)
mysql_backup="yes"
mysql_host=${DB_HOST}
mysql_user=${DB_USER}
mysql_pass=${DB_PASSWORD}


#################################################################
#################################################################
#################################################################

################
# Do the backup
################

case $1 in
    "--fresh" )
        rm /var/backup_lock 2> /dev/null;;
    *)
        :;;
esac

# Main variables
color='\033[0;36m'
color_fail='\033[0;31m'
nc='\033[0m'
hostname=$(hostname -s)
date_now=$(date +"%Y-%m-%d %H:%M:%S")

# Checking lock file
test -r /var/backup_lock
if [ $? -eq 0 ];then
    echo -e "\n ${color}--- $date_now There is another backup process. \n${nc}"
    echo "$date_now There is another backup process." >> $log_file
    echo -e "\n ${color}--- $date_now If not, run the script with --fresh argument. \n${nc}"
    exit
fi

touch /var/backup_lock 2> /dev/null
path_date=$(hostname -s)_$(date +"%Y-%m-%d-%H-%M-%S")
mkdir -p $backup_path/Backup/$path_date 2>> $log_file
echo -e "\n ${color}--- $date_now Backup started. \n${nc}"
echo "$date_now Backup started." >> $log_file

sleep 1

# Backing up the files
if [ $backup_files_enable = "yes" ]
then
    echo -e "\n ${color}--- $date_now Backing up files \n${nc}"
    echo "$date_now Backing up files" >> $log_file
    mkdir $backup_path/Backup/$path_date/custom_files | tee -a $log_file
    for backup_custom_files in $backup_files
    do
        echo "--> $backup_custom_files" | tee -a $log_file
        cp $backup_files $backup_path/Backup/$path_date/custom_files/ 2>> $log_file
    done
    echo
fi


sleep 1

# Backing up the directories
if [ $backup_dir_enable = "yes" ]
then
    echo -e "\n ${color}--- $date_now Backing up directories \n${nc}"
    echo "$date_now Backing up directories" >> $log_file
    for backup_dirs in $backup_directories
    do
        echo "--> $backup_dirs" | tee -a $log_file
            dir_name=`echo $backup_dirs | cut -d / -f2- | sed 's/\//-/g'`
        if [[ -d ${backup_dirs}/.git ]]; then
            tar -cjf $backup_path/Backup/$path_date/$dir_name.tar.bz2 -X ${backup_dirs}/.gitignore $backup_dirs/ > /dev/null 2> /dev/null
        else
            tar -cjf $backup_path/Backup/$path_date/$dir_name.tar.bz2 $backup_dirs/ > /dev/null 2> /dev/null
        fi
    done
    echo
fi

sleep 1

# MySQL backup
if [ $mysql_backup = "yes" ]
then
    echo -e "\n ${color}--- $date_now MySQL backup enabled, backing up: \n${nc}"
    echo "$date_now MySQL backup enabled, backing up" >> $log_file
    # Using ionice for MySQL dump
    ionice -c 3 mysqldump -h $mysql_host -u $mysql_user -p$mysql_pass --events --all-databases | gzip -9 > $backup_path/Backup/$path_date/MySQL_Full_Dump_$path_date.sql.gz | tee -a $log_file
    if [ $? -eq 0 ]
    then
        echo -e "\n ${color}--- $date_now MySQL backup completed. \n${nc}"
        echo "$date_now Backing up files" >> $log_file
    fi
fi

sleep 1


############################################################################################

# Create TAR file
echo -e "\n ${color}--- $date_now Creating TAR file located in $backup_path/Full_Backup_$path_date.tar.bz2 \n${nc}"
echo "$date_now Creating TAR file located in $backup_path/Full_Backup_$path_date.tar.bz2" >> $log_file
tar -cjf $backup_path/Full_Backup_${path_date}.tar.bz2 $backup_path/Backup/$path_date 2> /dev/null
rm -rf $backup_path/Backup/
final_archive="Full_Backup_${path_date}.tar.bz2"

sleep 1

############################################################################################

# Upload to FTP server
if [ $ftp_enable = "yes" ]
then
    if [ `which curl` ]
    then
        echo -e "\n ${color}--- $date_now Uploading backup archive to FTP server $ftp_server \n${nc}"
        echo "$date_now Uploading backup archive to FTP server $ftp_server" >> $log_file
        curl --connect-timeout 30 -S -T $backup_path/$final_archive ftp://$ftp_server/$ftp_path --user $ftp_username:$ftp_password | tee -a $log_file
        if [ $? -eq 0 ]
        then
            echo "$date_now FTP Upload Done" | tee -a $log_file
        else
            echo -e "\n ${color_fail}--- $date_now FTP upload failed. \n${nc}"
            echo "$date_now FTP upload failed. Please investigate." >> $log_file
        fi
    else
        echo -e " ${color_fail}--- $date_now You have been enabled FTP upload. ${nc}"
        echo -e " ${color_fail}--- $date_now You need to install curl package. ${nc}"
        echo -e " ${color_fail}--- $date_now FTP upload failed. ${nc}"
        echo "$date_now FTP upload failed. Install 'curl' package." >> $log_file
    fi
fi

# Send a simple email notification
if [ $send_email = "yes" ]
then
    echo -e "Backup completed $date_now\nBackup path: $backup_path/$final_archive" | mail -s "Backup Result" $email_to >> $log_file 2>&1
fi

echo -e "\n"
echo -e "###########################################################"
echo -e "$date_now Backup finished"
echo -e "Backup path: $backup_path/$final_archive"
echo -e "###########################################################"
echo -e "\n"
echo "$date_now Backup finished. Backup path: $backup_path/$final_archive" >> $log_file
echo "#######################" >> $log_file

# Removing lock after successful backup
rm /var/backup_lock

#Removing apache log file after cron
> /site-to-save/misc/logs/access.log
> /site-to-save/misc/logs/error.log

exit 0