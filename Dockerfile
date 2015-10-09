FROM centos:latest

RUN yum -y update
RUN curl -sSL https://get.docker.com/ | sh
RUN curl --silent --location https://rpm.nodesource.com/setup | bash -
RUN yum -y install nodejs

CMD ["npm", "start"]

