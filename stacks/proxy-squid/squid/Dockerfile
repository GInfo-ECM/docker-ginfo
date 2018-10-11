FROM sameersbn/squid
COPY squid.conf /etc/squid/squid.conf
RUN touch /etc/squid/utilisateurs
RUN apt update && apt install -y apache2-utils && apt install -y nano && apt install -y net-tools && apt install -y iproute2

#Gestion de l'heure
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#On met une gateway par defaut pour acceder a internet
ARG GATEWAY
RUN echo "ip route del default" >> /sbin/entrypoint.sh
RUN echo "ip route add default via $GATEWAY" >> /sbin/entrypoint.sh

