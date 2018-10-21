#!/bin/bash
#Fonctions
function mailing(){
mail -s $1 monitoring@domain.mail.ltd -r bor+ginfo@centrale-marseille.fr -a "From: ginfo-monitoring" <<< $2
echo "Mail d'avertissement envoyé"
}

#Script qui envoie un mail si la file d'attente est surchargée
service postfix start

while true
do
    queue=$(mailq | grep -c "^[A-F0-9]")

	if [ "${queue:-0}" -ge "5" ]; then

        echo "Activitée anormale détectée"
        echo $(mailq)
        mailing "Activite anormale sur le serveur mail" "Une activité anormale a été détectée sur le serveur mail : \n\n"$(mailq)
        echo "Mail d'avertissement envoyé"

        sleep 600

        else

        echo $(mailq)

        sleep 60

    fi

done