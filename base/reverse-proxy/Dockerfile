FROM jwilder/nginx-proxy

COPY network_internal.conf /etc/nginx/network_internal.conf

#Gestion de l'heure
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone