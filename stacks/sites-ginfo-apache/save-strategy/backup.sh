#!/bin/bash
#
# bash-backup V1.1
#################################################################
# You need megatools in order to upload your backup file to MEGA
# Download megatools from http://megatools.megous.com/
#################################################################
# Simple backup script for GNU/Linux servers
# Main features:
#   - Backup custom files and directories
#   - Backup MySQL/PostgreSQL/MongoDB databases
#   - Copy/SCP/FTP to another server or mounted media
#   - Upload to MEGA.nz cloud
#   - Send a notification to your email
#   - Logging all the activities
#   - Encrypts backup file using GPG
#   - Backup multiple MariaDB/MySQL docker containers
#
# Edit the configuration and run:
#   $ sudo bash backup.sh
#
#################################################################

################
# Configuration
################

# Server Name
server_name="localhost"

# Backup path
backup_path="/saves"

# Script log file
log_file="/saves/backup.log"

# Files to backup (Multi value)
backup_files_enable="no"
backup_files="/root/.bash_history /etc/passwd"

# Directories to backup (Multi value)
backup_dir_enable="yes"
backup_directories="/site-to-save"

# Copy to other media (Multi value)
external_copy="no"
external_storage="/mnt"

# SCP to other server (Trusted servers for now)
scp_enable="no"
scp_server="1.2.3.4"
scp_port="22"
scp_username="root"
scp_path="/media/backups"

# Enable iptables backup
iptables_backup="no"

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

# Encrypt archive file using GPG
gpg_enable="no"
gpg_public_recipient=""

# Upload to MEGA.nz if you have installed the client.
# /Root/ is the main directory in MEGA.nz
mega_enable="no"
mega_email=""
mega_pass=""
mega_path="/Root/backups" # /Root/ should always be here.

# Full MySQL dump (All Databases)
mysql_backup="yes"
mysql_host=${DB_HOST}
mysql_user=${DB_USER}
mysql_pass=${DB_PASSWORD}

# Full PostgreSQL dump (All Databases)
postgres_backup="no"
postgres_user=""
postgres_pass=""
postgres_database=""
postgres_host="localhost"
postgres_port="5432"

# MongoDB collection dump (MongoDB Version +3)
mongo_backup="no"
mongo_host="localhost"
mongo_port="27017"
mongo_database=""
mongo_collection=""

# Docker Mariadb/Mysql dump config
# pattern of backup most be like containerID:::user:::password:::database
# This script can backup multiple container with this pattern

docker_mysql_backup="no"
docker_mysql_containers=""

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

if [ $iptables_backup = "yes" ]
then
        echo -e "\n ${color}--- $date_now Backing up iptables rules \n${nc}"
        echo "$date_now Backing up iptables rules" >> $log_file
    iptables-save >> $backup_path/Backup/$path_date/custom_files/iptables-save
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
    ionice -c 3 -h $mysql_host -u $mysql_user -p$mysql_pass --events --all-databases | gzip -9 > $backup_path/Backup/$path_date/MySQL_Full_Dump_$path_date.sql.gz | tee -a $log_file
    if [ $? -eq 0 ]
    then
        echo -e "\n ${color}--- $date_now MySQL backup completed. \n${nc}"
        echo "$date_now Backing up files" >> $log_file
    fi
fi

sleep 1

# PostgreSQL backup
if [ $postgres_backup = "yes" ]
then
    # Creating ~/.pgpass for PostgreSQL password
    # PostgreSQL does not support inline password
    # Know better solution? Let me know.
    USERNAME=`whoami`
    CUR_DATE=$(date +"%Y-%m-%d-%H-%M-%S")
    if [ $USERNAME = "root" ]
    then
        echo "$postgres_host:$postgres_port:$postgres_database:$postgres_user:$postgres_pass" > /root/.pgpass
        chmod 600 /root/.pgpass
    else
        echo "$postgres_host:$postgres_port:$postgres_database:$postgres_user:$postgres_pass" > /home/$USERNAME/.pgpass
        chmod 600 /home/$USERNAME/.pgpass
    fi

    echo -e "\n ${color}--- $date_now PostgreSQL backup enabled, backing up: \n${nc}"
    echo "$date_now PostgreSQL backup enabled, backing up" >> $log_file
    # Using ionice for PostgreSQL dump
    ionice -c 3 pg_dump -p $postgres_port -h $postgres_host -Fc -U $postgres_user $postgres_database > ${backup_path}/Backup/${path_date}/Postgres_Full_Dump_${path_date}.dump | tee -a $log_file
    if [ $? -eq 0 ]
    then
        echo -e "\n ${color}--- $date_now PostgreSQL backup completed. \n${nc}"
        echo "$date_now PostgreSQL backup completed" >> $log_file
    fi
fi

sleep 1

# MongoDB backup
if [ $mongo_backup = "yes" ]
then
    echo -e "\n ${color}--- $date_now MongoDB backup enabled, backing up: \n${nc}"
    echo "$date_now MongoDB backup enabled, backing up" >> $log_file
    # Using ionice for MongoDB dump
    ionice -c 3 mongodump --host $mongo_host --collection $mongo_collection --db $mongo_database --gzip --archive=${backup_path}/Backup/${path_date}/MongoDB_${mongo_collection}_${path_date}.dump | tee -a $log_file
    if [ $? -eq 0 ]
    then
        echo -e "\n ${color}--- $date_now MongoDB backup completed. \n${nc}"
        echo "$date_now MongoDB backup completed" >> $log_file
    fi
fi

sleep 1

# Docker Backup
# Mariadb or Mysql backup

if [ $docker_mysql_backup = "yes" ]
then
    echo -e "\n ${color}--- $date_now Docker Mariadb/MySQL backup enabled, backing up: \n${nc}"
    echo "$date_now Docker MySQL backup enabled, backing up" >> $log_file
    for docker_mysql_container in $docker_mysql_containers
        do
            docker_mysql_container_id=`echo $ocker_mysql_container | awk -F":::" '{print $1}'`
            docker_mysql_container_name=`docker ps --filter "id=$docker_mysql_container_id" | awk '{print $11}'`
            docker_mysql_user=`echo $ocker_mysql_container | awk -F":::" '{print $2}'`
            docker_mysql_pass=`echo $ocker_mysql_container | awk -F":::" '{print $3}'`
            docker_mysql_database=`echo $ocker_mysql_container | awk -F":::" '{print $4}'`
            docker exec $docker_mysql_container_id /usr/bin/mysqldump -u $docker_mysql_user --password=$docker_mysql_pass $docker_mysql_database | gzip -9 > $backup_path/Backup/$path_date/Docker_MySQL_${docker_mysql_container_name}_Dump_$path_date.sql.gz | tee -a $log_file
    if [ $? -eq 0 ]
    then
        echo -e "\n ${color}--- $date_now Docker Mariadb/MySQL backup completed. \n${nc}"
        echo "$date_now Docker Mariadb/MySQL backup completed" >> $log_file
    fi
    done
fi


############################################################################################

# Create TAR file
echo -e "\n ${color}--- $date_now Creating TAR file located in $backup_path/Full_Backup_$path_date.tar.bz2 \n${nc}"
echo "$date_now Creating TAR file located in $backup_path/Full_Backup_$path_date.tar.bz2" >> $log_file
tar -cjf $backup_path/Full_Backup_${path_date}.tar.bz2 $backup_path/Backup/$path_date 2> /dev/null
rm -rf $backup_path/Backup/
final_archive="Full_Backup_${path_date}.tar.bz2"

sleep 1

############################################################################################

# Encrypt using GPG
if [ $gpg_enable = "yes" ]
then
    echo -e "\n ${color}--- $date_now Encrypting archive file using $gpg_public_recipient key\n${nc}"
    echo "$date_now Encrypting archive file using $gpg_public_recipient key" >> $log_file
    gpg --yes --always-trust -e -r $gpg_public_recipient $backup_path/Full_Backup_${path_date}.tar.bz2
    # Removing the unencrypted archive file
    rm $backup_path/Full_Backup_${path_date}.tar.bz2
    final_archive="Full_Backup_${path_date}.tar.bz2.gpg"
fi

sleep 1

# Copy to other storage
if [ $external_copy = "yes" ]
then
    for cp_paths in $external_storage
    do
        echo -e "\n ${color}--- $date_now Copy backup archive to $cp_paths: \n${nc}"
        echo "$date_now Copy backup archive to $cp_paths" >> $log_file
        cp $backup_path/$final_archive $cp_paths/
        if [ $? -eq 0 ]
        then
            echo -e "Copied to $cp_paths. \n"
            echo "$date_now Copied to $cp_paths" >> $log_file
        else
            echo -e " ${color_fail} Copy to $cp_paths failed. ${nc} \n"
            echo "$date_now Copy to $cp_paths failed. Please investigate." >> $log_file
        fi
    done
fi

sleep 1

# SCP to other server
if [ $scp_enable = "yes" ]
then
    echo -e "\n ${color}--- $date_now SCP backup archive to $scp_server: \n${nc}"
    echo "$date_now SCP backup archive to $scp_server" >> $log_file
    scp -P $scp_port $backup_path/$final_archive '$scp_username'@'$scp_server':$scp_path
    echo "$date_now SCP done" | tee -a $log_file
fi

sleep 1

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

# Upload archive file to MEGA.nz
if [ $mega_enable = "yes" ]
then
    if [ `which megaput` ]
    then
        echo -e "\n ${color}--- $date_now Uploading backup archive to MEGA.nz \n${nc}"
        echo "$date_now Uploading backup archive to MEGA.nz" >> $log_file
        megaput --reload --path $mega_path -u $mega_email -p $mega_pass $backup_path/$final_archive
        echo "$date_now MEGA Upload Done. Path: $mega_path" | tee -a $log_file
    else
        echo -e " ${color_fail}--- $date_now You have been enabled MEGA upload. ${nc}"
        echo -e " ${color_fail}--- $date_now You need to install megatools from http://megatools.megous.com ${nc}"
        echo -e " ${color_fail}--- $date_now MEGA upload failed. ${nc}"
        echo "$date_now Uploading to MEGA.nz failed. Install 'megatools' from http://megatools.megous.com" >> $log_file
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

exit 0