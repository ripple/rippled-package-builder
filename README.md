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

- GITHUB_WEBHOOK_SECRET
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- S3_BUCKET

## Usage

Upon receipt of a release message from github the software
will launch a docker container that builds an RPM with the
given release. The following command is executed:

```
sudo docker run -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e "RIPPLED_BRANCH=release" -e S3_BUCKET=rpm-builder-test -v $PWD:/opt/rippled-rpm/out -it rippled-rpm-builder
```

