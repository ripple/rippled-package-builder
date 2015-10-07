docker tag rippled-build-bot quay.io/stevenzeiler/rippled-build-bot:$CIRCLE_SHA
docker tag rippled-build-bot quay.io/stevenzeiler/rippled-build-bot:$1
docker login --email=$DOCKER_EMAIL --username=$DOCKER_USERNAME --password=$DOCKER_PASSWORD quay.io
docker push quay.io/stevenzeiler/rippled-build-bot:$CIRCLE_SHA
docker push quay.io/stevenzeiler/rippled-build-bot:$1
