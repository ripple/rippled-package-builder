FROM node:4.1.0-onbuild

USER root

RUN apt-get update --fix-missing
RUN curl -sSL https://get.docker.com/ | sh

