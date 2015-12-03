# Rippled Package Builder

Docker images for building and testing rippled rpms

## Dependencies

- docker

## rpm-builder

The rpm-builder docker container builds a rippled rpm from the specified git branch and uploads the rpm to an AWS S3 bucket.

Writes `md5sum`, `rippled_version`, and `s3key` to `build_vars` file in mounted directory.

### Configuration

All configuration is performed via environment variables:

- GIT_BRANCH: rippled branch to package
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- S3_BUCKET
- S3_REGION

### Build

```
docker build -t rippled-rpm-builder rpm-builder/
```

### Run

```
docker run -e GIT_BRANCH=develop -e AWS_ACCESS_KEY_ID=your-key-id -e AWS_SECRET_ACCESS_KEY=your-access-key -e S3_BUCKET=your-bucket -e S3_REGION=your-region -v <path-to-put-build_vars_dir>:/out rippled-rpm-builder
```

## rpm-tester

Installs rippled rpm from test-mirrors.ripple.com yum repository and runs tests.

### Configuration

All configuration is performed via environment variables:

- YUM_REPO: `ripple-stable`/`ripple-unstable`/`ripple-nightly`
- RIPPLED_VERSION
- MD5SUM: from `rpm -Kv <rippled.rpm>`

### Build

```
docker build -t rippled-rpm-tester rpm-tester/
```

### Run

```
docker run -e YUM_REPO=ripple-stable -e RIPPLED_VERSION=0.30.0_hf1 -e MD5SUM=330148032dd232de9a940f0890b698f3 rippled-rpm-tester
```
