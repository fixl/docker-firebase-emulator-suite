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
docker run --rm -it --net host -e FIRESTORE='true' -e FIRESTORE_RULES_FILE=/src/firestore.rules -v $(pwd)/src -w /src fixl/firebase-emulator-suite
```

## Configuration

You can enable services by specifying environment variables:

| Name                       | Description                                                         | Default                    |
|:---------------------------|:--------------------------------------------------------------------|:---------------------------|
| `FIREBASE_PROJECT_ID`      | The project ID to be used for this emulator                         | `local`                    |
| `FIREBASE_TOKEN`           | Token used for firebase commands                                    | N/A                        |
| `UI_PORT`                  | The port at which the UI will be exposed                            | `4000`                     |
| `HOSTING`                  | If set to `true`, hosting emulator will be enabled on port `5000`   | N/A                        |
| `HOSTING_PORT`             | Enabled the hosting emulator at the provided port                   | `5000` if `HOSTING=true`   |
| `FUNCTIONS`                | If set to `true`, functions emulator will be enabled on port `5001` | N/A                        |
| `FUNCTIONS_PORT`           | Enabled the functions emulator at the provided port                 | `5001` if `FUNCTIONS=true` |
| `FIRESTORE`                | If set to `true`, firestore emulator will be enabled on port `8081` | N/A                        |
| `FIRESTORE_PORT`           | Enabled the firestore emulator at the provided port                 | `8081` if `FIRESTORE=true` |
| `FIRESTORE_RULES_FILE`     | Specify the firestore rules file to use                             | N/A                        |
| `FIRESTORE_WEBSOCKET_PORT` | Specify the websocket to use for the request tab in the UI to work. | N/A (Random open port)     |
| `PUBSUB`                   | If set to `true`, pubsub emulator will be enabled on port `8085`    | N/A                        |
| `PUBSUB_PORT`              | Enabled the pubsub emulator at the provided port                    | `8085` if `PUBSUB=true`    |
| `DATABASE`                 | If set to `true`, database emulator will be enabled on port `9000`  | N/A                        |
| `DATABASE_PORT`            | Enabled the database emulator at the provided port                  | `9000` if `DATABASE=true`  |
| `DATABASE_RULES_FILE`      | Specify the database rules file to use                              | N/A                        |
| `AUTH`                     | If set to `true`, auth emulator will be enabled on port `9099`      | N/A                        |
| `AUTH_PORT`                | Enabled the auth emulator at the provided port                      | `9099` if `AUTH=true`      |
| `STORAGE`                  | If set to `true`, storage emulator will be enabled on port `9199`   | N/A                        |
| `STORAGE_PORT`             | Enabled the storage emulator at the provided port                   | `9199` if `STORAGE=true`   |
| `STORAGE_RULES_FILE`       | Specify the store rules file to use                                 | `/storage.rules`           |

## Health check

To add a health check for the emulator container, add something like the following to your `docker-compose.yml`:

```yaml
    healthcheck:
      test: /usr/bin/wget -qO- http://localhost:4000
      timeout: 30s
      interval: 3s
      retries: 20
```

If you run the UI on a non-standard port, you'll have to amend the port accordingly.
