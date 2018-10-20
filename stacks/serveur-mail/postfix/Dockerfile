FROM ubuntu:bionic
MAINTAINER pnahoum

# apt-get non interactif
ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get update

# Installation des packets
RUN apt-get -y install supervisor postfix sasl2-bin opendkim opendkim-tools

# Add files
ADD assets/install.sh /opt/install.sh

# Run
CMD /bin/bash