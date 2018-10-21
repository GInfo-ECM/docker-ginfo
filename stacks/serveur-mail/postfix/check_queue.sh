#!/bin/bash
#Script qui envoie un mail si la file d'attente est surchargée
while true
do
    queue=$(mailq | grep -c "^[A-F0-9]")

	if [ "${queue:-0}" -ge "5" ]; then

    echo $(mailq)
    sleep 600

    else

    echo "Pas de soucis"
    sleep 60

    fi

done