# DockaGator

[![Travis Build Status](https://travis-ci.com/GatorEducator/dockagator.svg?branch=master)](https://travis-ci.com/GatorEducator/dockagator)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/gatoreducator/dockagator.svg?style=popout)](https://hub.docker.com/r/gatoreducator/dockagator)

This repository contains the infrastructure needed to generate a Docker image
that can run [GatorGradle](https://github.com/GatorEducator/gatorgradle)
on an assignment or project.

## Build

Simply run `./build.sh` to generate a new image locally.

## Run

Execute the following `docker run` command to start `gradle grade` as a
containerized application.

```bash
docker run --rm --name dockagator \
  -v "$(pwd)":/project \
  -v "dockagator":/root/.local/share \
  gatoreducator/dockagator
```

This will use `"$(pwd)"` (the current directory) as the project directory and create
a separate Docker Volume for the GatorGrader installation; the project directory must exist
and contain something. To view the cache volume you can use an interactive container;
this can be used both to run back-to-back `gradle grade` commands, or inspect
`/root/.local/share`, which is where the volume is mounted.

```bash
docker run -it --rm --name dockagator \
  -v "$(pwd)":/project \
  -v "dockagator":/root/.local/share \
  gatoreducator/dockagator /bin/bash
```
