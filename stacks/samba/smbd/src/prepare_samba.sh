#!/bin/bash

if [ ! -f /var/lib/samba/.initialized ]; then
  echo "Initializing /var/lib/samba. Please be patient..."
  apt-get update
  #SAMBA_URI=$(apt-cache show samba | grep "Filename:" | cut -f 2 -d " ")
  #wget "http://ftp.debian.org/debian/${SAMBA_URI}" -O /tmp/samba.deb
  #dpkg -x /tmp/samba.deb /tmp/samba
  #cp -r /tmp/samba/var/lib/samba/* /var/lib/samba
  mkdir -p /var/lib/samba/private
  mkdir -p /var/lib/samba/usershares
  rm -rf /tmp/*
  smbpasswd -an nobody
  touch /var/lib/samba/.initialized
fi
