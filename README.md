# DockaGator

[![Travis Build Status](https://travis-ci.com/GatorEducator/dockagator.svg?branch=master)](https://travis-ci.com/GatorEducator/dockagator)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/gatoreducator/dockagator.svg?style=popout)](https://hub.docker.com/r/gatoreducator/dockagator)

This repository contains the infrastructure needed to generate a Docker image
that can run [GatorGradle](https://github.com/GatorEducator/gatorgradle)
on an assignment or project.

## Build

Simply run `./build.sh` to generate a new image.

## Run

Execute the following `docker run` command to start `gradle grade` as a
containerized application.

```bash
docker run --rm --name dockagator \
  -v "$(pwd)":/project \
  -v "$HOME/.gatorgrader":/root/.local/share \
  gatoreducator/dockagator
```

This will use `"$(pwd)"` as the project directory and `"$HOME/.dockagator"` as
the cached GatorGrader directory; both directories must exist, although only the
project directory must contain something.
