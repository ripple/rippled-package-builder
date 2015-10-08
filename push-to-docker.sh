docker tag rippled-build-bot stevenzeiler/rippled-build-bot:$CIRCLE_SHA
docker tag rippled-build-bot stevenzeiler/rippled-build-bot:$1
docker login --email=$DOCKER_EMAIL --username=$DOCKER_USERNAME --password=$DOCKER_PASSWORD
docker push stevenzeiler/rippled-build-bot:$CIRCLE_SHA
docker push stevenzeiler/rippled-build-bot:$1
