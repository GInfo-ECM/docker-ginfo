#!/bin/bash
#Fonctions
function mailing(){
mail -s "$1" monitoring@domain.mail.ltd -a "From: Serveur Mail du GInfo <no-reply@centrale-marseille.fr>" <<< "$2"
echo "Mail d'avertissement envoyé"
}

#Script qui envoie un mail si la file d'attente est surchargée
service postfix start

while true
do
    queue=$(mailq | grep -c "^[A-F0-9]")

	if [ "${queue:-0}" -ge "30" ]; then

        echo "Activité anormale détectée"
        echo $(mailq)
        mailing "Postfix" "Une activité anormale a été détectée sur le serveur mail :$(mailq)"

        sleep 86400

        else

        echo $(mailq)

        sleep 60

    fi

done