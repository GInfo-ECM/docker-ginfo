#!/bin/bash
#Gestion de la création du dossier par défaut (si jamais supprimé ou premier démarrage)
mkdir -p ${APACHE_DOCUMENT_ROOT}

#Gestion de PhpMyAdmin au démarrage - ne pas supprimer (sauf si vous ne voulez plus de PhpMyAdmin)
htpasswd -b -c /phpmyadmin/.htpasswd ${DB_USER} ${DB_PASSWORD}
rm -f ${APACHE_DOCUMENT_ROOT}/phpmyadmin-ginfo
ln -s /phpmyadmin ${APACHE_DOCUMENT_ROOT}/phpmyadmin-ginfo
rm -R /phpmyadmin/tmp
mkdir /phpmyadmin/tmp
chmod 777 /phpmyadmin/tmp
rm -f /phpmyadmin/config.inc.php
randomBlowfishSecret=`openssl rand -base64 32`;
sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" /phpmyadmin/config.sample.inc.php > /phpmyadmin/config.inc.php
sed -i 's/localhost/db/g' /phpmyadmin/config.inc.php
#Autres instructions