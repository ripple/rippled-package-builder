FROM node:4.1.0-onbuild

USER root

RUN apt-get update
RUN curl -sSL https://get.docker.com/ | sh

