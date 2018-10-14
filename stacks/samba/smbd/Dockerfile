FROM debian:jessie
MAINTAINER Pierre NAHOUM <pnahoum@ec-m.fr>

VOLUME /var/lib/extrausers
VOLUME /var/lib/samba
VOLUME /etc/samba
VOLUME /data/public
VOLUME /home

#Maj et installation des packets nécéssaires
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  libnss-extrausers \
  wget \
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i '/^\(passwd\|group\|shadow\):/{ s/$/ extrausers/; }' /etc/nsswitch.conf

#Configuration des scripts de gestion
COPY src /opt/rootlogin-fileserver
RUN chmod +x /opt/rootlogin-fileserver/*.sh

#Configuration de samba
COPY smb.conf /etc/samba/smb.conf

#Installation de samba
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  samba \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#Exposition des ports
EXPOSE 135
EXPOSE 139
EXPOSE 445

#Lancement
RUN chmod +x /opt/rootlogin-fileserver/run.sh
ENTRYPOINT ["/opt/rootlogin-fileserver/run.sh"]
CMD ["/usr/sbin/smbd", "-s", "/etc/fileserver/smb.conf", "-F", "-S"]
