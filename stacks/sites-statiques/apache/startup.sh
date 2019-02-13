#!/bin/bash
#Gestion de la création du dossier par défaut (si jamais supprimé ou premier démarrage)
mkdir -p ${APACHE_DOCUMENT_ROOT}
#Importation des variables d'environnement
> /etc/environment
echo "export APACHE_LOG_DIR=${APACHE_LOG_DIR}" >> /etc/environment
#Autres instructions