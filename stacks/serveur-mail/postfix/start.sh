#!/bin/bash
#Script qui envoie un mail si la file d'attente est surchargée
service postfix start

while true
do
    queue=$(mailq | grep -c "^[A-F0-9]")

	if [ "${queue:-0}" -ge "5" ]; then

    echo $(mailq)
    sleep 600
    mailing "Activite anormale sur le serveur mail" "Une activité anormale a été détectée sur le serveur mail : \n"$(mailq)

    else

    echo $(mailq)
    sleep 60

    fi

done


mailing(){
mail -s $1 monitoring@domain.mail.ltd -r bor+ginfo@centrale-marseille.fr -a "From: ginfo-monitoring" <<< $2
echo "Mail d'avertissement envoyé"
}