FROM node:4.1.0-onbuild

RUN echo "deb http://http.debian.net/debian jessie-backports main contrib non-free" >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y install docker.io

