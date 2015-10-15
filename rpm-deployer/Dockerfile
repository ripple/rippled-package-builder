FROM williamyeh/ansible:ubuntu14.04

COPY ./ /home/docker/rpm-deployer

# This is a workaround for 'Host key verification failed' error from ansible-playbook
RUN mkdir /root/.ssh
COPY ssh-config /root/.ssh/config
RUN chmod 600 /root/.ssh/config

CMD cd /home/docker/rpm-deployer/ansible && ansible-playbook -vvv -i hosts staging.yml
