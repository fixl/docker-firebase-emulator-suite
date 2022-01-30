# Firebase Emulator Suite Image

[![pipeline status](https://gitlab.com/fixl/docker-firebase-emulator-suite/badges/master/pipeline.svg)](https://gitlab.com/fixl/docker-firebase-emulator-suite/-/pipelines)
[![version](https://fixl.gitlab.io/docker-firebase-emulator-suite/version.svg)](https://gitlab.com/fixl/docker-firebase-emulator-suite/-/commits/master)
[![size](https://fixl.gitlab.io/docker-firebase-emulator-suite/size.svg)](https://gitlab.com/fixl/docker-firebase-emulator-suite/-/commits/master)
[![Docker Pulls](https://img.shields.io/docker/pulls/fixl/firebase-emulator-suite)](https://hub.docker.com/r/fixl/firebase-emulator-suite)
[![Docker Stars](https://img.shields.io/docker/stars/fixl/firebase-emulator-suite)](https://hub.docker.com/r/fixl/firebase-emulator-suite)

A Docker container containing [Firebase CLI](https://github.com/firebase/firebase-tools), with
pre-installed simulators, and an easy way to manage which emulator you want to use.

## Build the image

```bash
make build
```

## Inspect the image

```bash
docker inspect --format='{{ range $k, $v := .Config.Labels }}{{ printf "%s=%s\n" $k $v}}{{ end }}' fixl/firebase-emulator-suite:latest
```

## Usage

```bash
docker run --rm -it --net host -e FIRESTORE='true' fixl/firebase-emulator-suite
```
