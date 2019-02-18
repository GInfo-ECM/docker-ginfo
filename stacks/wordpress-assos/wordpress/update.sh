#!/bin/bash
############ Définition des variables ############
logfile=/var/log/wpupdate-last.log
mailfilehtml=/var/log/wpupdate-last.log.html
rm -rf $logfile
rm -rf $mailfilehtml
exec > $logfile 2>&1
siteurl=$(wp option get siteurl --path='/var/www/html')
email=$(wp option get admin_email --path='/var/www/html')
#Mailing list de suivi de la plateforme
email_list="d@ec-m.fr"
d=$(date)
errorCount=0

#Execute une commande Wordpress et défini si la sortie contient une erreur ou non
#Evalue une commande et retourne sont contenu en fonction de si elle contient Error ou Warning ou rien
evalCommand () {
    eval $1 > /tmp/tempwpfile 2>&1
    cmdoutput=$(cat /tmp/tempwpfile)
    if [[ $cmdoutput == *"Error"* ]]; then
        echo "\e[0m\e[31m$(< /tmp/tempwpfile)\e[0m"
        errorCount=$((errorCount+1))
    elif [[ $cmdoutput == *"Warning"* ]]; then
        echo "\e[0m\e[33m$(< /tmp/tempwpfile)\e[0m"
        errorCount=$((errorCount+1))
    else
        echo "\e[0m\e[32m$(< /tmp/tempwpfile)\e[0m"
    fi
    rm /tmp/tempwpfile
    }



############ Début des tâches routinières ############
cd /var/www/html

echo "\e[1mRapport des tâches routinières du "$d" pour le site "$siteurl"\e[0m"

echo "strerror"

echo "\n\e[1m------ WP CLI ------\e[0m"
evalCommand 'wp cli update'

echo "\n\e[1m------ Core Wordpress, plugins et templates ------\e[0m"

echo "\n\e[34m-- Core Wordpress --\e[0m"
evalCommand 'wp core update --path="/var/www/html"'

echo "\n\e[34m-- DB du Core --\e[0m"
evalCommand 'wp core update-db --path="/var/www/html"'

echo "\n\e[34m-- Mise à jour des thèmes --\e[0m"
SHELL_PIPE=0 wp theme list
evalCommand 'wp theme update --all'

echo "\n\e[34m-- Mise à jour des plugins --\e[0m"
SHELL_PIPE=0 wp plugin list
evalCommand 'wp plugin update --all'

echo "\n\e[34m-- Suppression des thèmes dépréciés --\e[0m"
evalCommand '/usr/lib/wp-theme-remove'

echo "\n\e[34m-- Suppression des plugins dépréciés --\e[0m"
evalCommand '/usr/lib/wp-plugin-remove'

echo "\n\n\e[1m------ Informations supplémentaires ------\e[0m"
echo "\n\e[34m-- Espace disque disponible --\e[0m"
df /

echo "\n\n\e[1mCe mail a été envoyé à $email et à la mailing list du GInfo $email_list"
echo "Cette plateforme est gérée par le GInfo, merci de le contacter en cas de problème avec ce rapport."


############ Envoi du rapport par mail ############
if [ "$errorCount" != "0" ]
then
      errorHeader="[Important rapport]"
      errorString="\\\e[31mCe rapport contient $errorCount erreur(s) ou message(s) d'alerte requérant votre attention \\\e[0m"
else
      errorHeader="[Rapport]"
      errorString=""
fi


header="To:$email,$email_list\nSubject:$errorHeader Rapport des tâches routinières du $d pour le site $siteurl\nMIME-Version: 1.0\r\nContent-Type: text/html; charset=utf-8"
echo -e $header > $mailfilehtml
sed -i -e "s/strerror/$errorString/g" $logfile
echo -e "$(< $logfile)" | ansi2html -w >> $mailfilehtml
/usr/sbin/sendmail -t < /var/log/wpupdate-last.log.html

############ Nettoyage ############
rm $mailfilehtml