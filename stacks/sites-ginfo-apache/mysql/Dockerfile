FROM mysql:5.7

#Gestion de l'heure
RUN apt-get update && apt install -y tzdata
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone