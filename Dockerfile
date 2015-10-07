FROM centos:latest

RUN yum -y update
RUN curl -sSL https://get.docker.com/ | sh

CMD ["docker", "run", "hello-world"]
