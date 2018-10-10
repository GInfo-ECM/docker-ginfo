FROM sameersbn/squid
COPY squid.conf /etc/squid/squid.conf
RUN touch /etc/squid/utilisateurs
RUN apt-get update && apt-get install -y apache2-utils && apt-get install -y nano

#Gestion de l'heure
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone