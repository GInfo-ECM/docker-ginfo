#!/bin/bash

############### Printing in a log file ################
logfile=/var/log/wpupdate-last.log
mailfilehtml=/var/log/wpupdate-last.log.html
exec > $logfile 2>&1

#Installer
siteurl=$(wp option get siteurl --path='/var/www/html')
email=$(wp option get admin_email --path='/var/www/html')
email_list="none@ec-m.fr"
d=$(date)
error="Error"
success="Success"

#Execute a wp cli command and checks if it returned an error or not (and colors it)
evalCommand () {
    eval $1 > /tmp/tempwpfile 2>&1
    cmdoutput=$(cat /tmp/tempwpfile)
    if [[ $cmdoutput == *"Error"* ]]; then
        echo "\e[0m\e[31m$(< /tmp/tempwpfile)\e[0m"
    else
        echo "\e[0m\e[32m$(< /tmp/tempwpfile)\e[0m"
    fi
    rm /tmp/tempwpfile
}

#########################
cd /var/www/html

echo "\e[1mRapport des tâches routinières du "$d" pour le site "$siteurl"\e[0m"

##### No need to update wp-cli
# wp cli update >> /var/log/wpcliupdate.log 2>&1

echo "\n\e[1m------ Core Wordpress, plugins et templates ------\e[0m"

echo "\n\e[34m------ Core Wordpress ------\e[0m"
evalCommand 'wp core update --path="/var/www/html"'

echo "\n\e[34m------ DB du Core ------\e[0m"
evalCommand 'wp core update-db --path="/var/www/html"'

echo "\n\e[34m------ Suppression des thèmes dépréciés ------\e[0m"
themeremove=$(/usr/lib/wp-theme-remove)
[ -z "$themeremove" ] && echo "\e[0m\e[32m OK : Aucun thème n'a été supprimé\e[0m" || echo "\e[31m"$themeremove"\e[0m\n"

echo "\n\e[34m------ Suppression des plugins dépréciés ------\e[0m"
pluginremove=$(/usr/lib/wp-plugin-remove)
[ -z "$pluginremove" ] && echo "\e[0m\e[32m OK : Aucun plugin n'a été supprimé\e[0m" || echo "\e[31m"$pluginremove"\e[0m\n"

echo "\n\e[34m------ Mise à jour des thèmes ------\e[0m"
SHELL_PIPE=0 wp theme list
evalCommand 'wp theme update --all'

echo "\n\e[34m------ Mise à jour des plugins ------\e[0m"
SHELL_PIPE=0 wp plugin list
evalCommand 'wp plugin update --all'

echo "\n\n\e[1m------ Informations supplémentaires ------\e[0m"
echo "\n\e[34m------ Espace disque disponible ------\e[0m"
df /


#Generation logfile
header="To:"$email","$email_list"\nSubject:Rapport des tâches routinières du "$d" pour le site "$siteurl"\nMIME-Version: 1.0\r\nContent-Type: text/html; charset=utf-8"
echo -e $header > $mailfilehtml
echo -e "$(< $logfile)" | ansi2html >> $mailfilehtml
sendmail -t < /var/log/wpupdate-last.log.html

