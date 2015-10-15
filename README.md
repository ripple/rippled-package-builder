# Bridges Application

Responds to events from the rippled repository on Github,
and runs the Rippled packaging processes to output RPM builds.

## Dependencies

- nodejs 4.1.0
- docker

## Setup

Install the node.js module dependencies:

```
npm install
```

The application relies on the rpm-builder images to exist, which must be
built first using the following command:

```
npm run rpm-builder:setup
```

## Configuration

All configuration is performed via environment variables:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- GPG_PASSPHRASE
- S3_BUCKET

`GPG_PASSPHRASE` should correspond to a gpg key named **Ripple Release Engineering**, which is used to sign built packages.

## Deployment

The following environment variables must be set to deploy from Circle CI

- DOCKER_EMAIL
- DOCKER_USERNAME
- DOCKER_PASSWORD

## Usage

Start the node.js build bot application, which will spawn subsequent containers to run build jobs:

```
docker run -it -v /var/run/docker.sock:/var/run/docker.sock -p 5000:5000 -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY rippled-build-bot
```

Upon receipt of a release message from github the software
will launch a docker container that builds an RPM with the
given release. The following command is executed:

```
sudo docker run -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e "RIPPLED_BRANCH=release" -e GPG_PASSPHRASE=<passphrase> -e S3_BUCKET=rpm-builder-test -v $PWD:/opt/rippled-rpm/out -it rippled-rpm-builder
```

