docker tag -f rippled-package-builder stevenzeiler/rippled-package-builder:$1
docker login --email=$DOCKER_EMAIL --username=$DOCKER_USERNAME --password=$DOCKER_PASSWORD
docker push stevenzeiler/rippled-package-builder:$1
