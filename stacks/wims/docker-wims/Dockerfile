FROM debian:stretch
MAINTAINER Elaad FURREEDAN <elaad.f@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE 1
EXPOSE 80
WORKDIR /home/wims

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt-get install -y --no-install-recommends \
    python3 \
    make \
    sudo \
    g++ \
    texlive-base \
    gnuplot \
    build-essential \
    pari-gp \
    units-filter \
    flex \
    bison \
    perl \
    liburi-perl \
    imagemagick \
    libgd-dev \
    wget \
    autoconf ant \
    yacas \
    gap \
    maxima \
    octave \
    graphviz \
    ldap-utils \
    scilab-cli \
    libwebservice-validator-html-w3c-perl \
    qrencode \
    fortune \
    unzip \
    libgmp-dev \
    openbabel \
    apt-transport-https \
    gnupg2 \
    dirmngr \
    apache2 \
    systemd

# Installing pip3
RUN wget "https://bootstrap.pypa.io/get-pip.py" && \
    python3 get-pip.py
RUN rm get-pip.py

RUN pip install requests

# Installing Git from source
RUN apt-get install -y --no-install-recommends git

# Installing povray 3.7 from non-free packet
RUN echo 'deb http://ftp.fr.debian.org/debian/ oldstable main non-free contrib'  >> /etc/apt/sources.list
RUN apt-get install -y --no-install-recommends povray=1:3.7.0.0-9+b3
RUN echo 'read+write* = /home/wims/tmp/sessions'  >> /etc/povray/3.7/povray.conf

# Installing Macaulay2
RUN echo 'deb https://faculty.math.illinois.edu/Macaulay2/Repositories/Debian stretch main'  >> /etc/apt/sources.list
RUN wget --no-check-certificate https://faculty.math.illinois.edu/Macaulay2/PublicKeys/Macaulay2-key
RUN apt-key add Macaulay2-key
RUN gpg2 --no-tty --keyserver keys.gnupg.net --recv-key CD9C0E09B0C780943A1AD85553F8BD99F40DCB31
RUN apt-get update -q
RUN apt-get install -y -q macaulay2

# Installing Wims 4.15e
RUN adduser --disabled-password --gecos "" wims
RUN adduser wims sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER wims
RUN sudo chown -R wims:wims .
RUN wget --no-check-certificate https://sourcesup.renater.fr/frs/download.php/file/5617/wims-4.15e.tgz
RUN tar xzf wims-4.15e.tgz
RUN rm wims-4.15e.tgz
RUN yes 2 | ./compile --mathjax --jmol --modules --geogebra --swac
USER root
RUN ./bin/setwrapexec
RUN ./bin/setwimsd
RUN /bin/bash -c "source /etc/apache2/envvars"
RUN echo 'ServerName 172.17.0.2' >> /etc/apache2/apache2.conf
RUN echo 'manager_site=172.17.0.2' > log/wims.conf
RUN echo 'site_manager=2' >> log/wims.conf
COPY config/myself /home/wims/log/classes/.connections/
COPY config/.def /home/wims/log/classes/9001/
RUN a2enmod cgi
#ENTRYPOINT ./bin/apache-config && service apache2 restart
