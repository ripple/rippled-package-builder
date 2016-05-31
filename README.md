# Rippled Package Builder

Docker image for building rippled rpms

The rpm-builder docker container builds a rippled rpm from the mounted rippled git repository and puts a tar.gz of rpms in a mounted directory.

Writes `md5sum`, `rippled_version`, and `rpm_file_name` variables to `build_vars` properties file in mounted directory.

## Dependencies

- [Docker](https://docs.docker.com/engine/installation/)
- local checkout of [rippled](https://github.com/ripple/rippled)

## Configuration

All configuration is performed via environment variables:

- RPM_RELEASE: rpm release number (default: 1)

## Build

```
docker build -t rippled-rpm-builder rpm-builder/
```

## Run

```
docker run -v <path-to-rippled-dir>:/opt/rippled-rpm/rippled rippled-rpm-builder
```

## Test

```
./run_centos7_test.sh
```
