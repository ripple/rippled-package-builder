# Rippled Package Builder

Docker image for building rippled rpms

The rpm-builder docker container builds a rippled rpm from the specified git branch and puts a tar.gz of rpms in a mounted directory.

Writes `md5sum`, `rippled_version`, and `rpm_file_name` variables to `build_vars` properties file in mounted directory.

## Dependencies

- docker

## Configuration

All configuration is performed via environment variables:

- GIT_BRANCH:  rippled branch to package (default: develop)
- GIT_COMMIT:  rippled commit to package (overrides GIT_BRANCH)
- GIT_REMOTE:  rippled remote repository (default: origin)
- RPM_RELEASE: rpm release number        (default: 1)

## Build

```
docker build -t rippled-rpm-builder rpm-builder/
```

## Run

```
docker run -e GIT_BRANCH=develop -v <path-to-out-dir>:/opt/rippled-rpm/out rippled-rpm-builder
```

## Test

```
./run_test.sh
```
