FROM jwilder/nginx-proxy

COPY network_internal.conf /etc/nginx/network_internal.conf

#Gestion de l'heure
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Taille de l'upload des fichiers
RUN { \
      echo 'client_max_body_size 100m;'; \
    } > /etc/nginx/conf.d/my_proxy.conf