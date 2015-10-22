# Rippled Package Builder

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
- S3_REGION
- S3_BUCKET_STABLE
- S3_BUCKET_UNSTABLE
- S3_BUCKET_NIGHTLY
- SQS_REGION
- SQS_QUEUE_COMMIT_PUSHED
- SQS_QUEUE_UPLOADED
- SQS_QUEUE_DEPLOYED
- SQS_QUEUE_TESTED
- SQS_QUEUE_FAILED
- SLACK_TOKEN

`GPG_PASSPHRASE` should correspond to a gpg private key named **Ripple Release Engineering**, which is used to sign built packages. Ansible deployment expects the gpg key to be found in /etc/gpg/private.key

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
given release.

The built rpm and source rpm are uploaded to S3 and deployed to the staging yum repository.

Finally, the rpm is installed from the staging yum repository and tested.
