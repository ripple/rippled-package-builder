# Bridges Application

Responds to events from the rippled repository on Github,
and runs the Rippled packaging processes to output RPM builds.

## Configuration

All configuration is performed via environment variables:

- GITHUB_WEBHOOK_SECRET

## Usage

Upon receipt of a release message from github the software
will launch a docker container that builds an RPM with the
given release. The following command is executed:

```
docker run -v $PWD:/opt/rippled-rpm/out -e "RIPPLED_BRANCH=release" rpm-builder
```

