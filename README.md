# Valheim server

[![Build Status](https://drone.krondor.fr/api/badges/nox/valheim/status.svg)](https://drone.krondor.fr/nox/valheim)

## Introduction

This repository contains the docker and helm chart to deploy a valheim server on kubernetes.

## Docker

The docker image is based on alpine and is always built upon the latest version of valheim server available on `steam`.

The server is wrapped in a script that traps the termination signals to gracefully exit the server and can optionnaly create backups on exit.

### Environment variables

The server can be customized via environment variables.

| Variable                | Default          | Description                                                                             |
| ----------------------- | ---------------- | --------------------------------------------------------------------------------------- |
| `BACKUP_DIR`            | `saves/backups`  | Location of the backups.                                                                |
| `BACKUP_ENABLED`        | `true`           | Wether to create a backup on exit or not.                                               |
| `BACKUP_RETENTION_DAYS` | `30`             | Backups older than this value will be removed upon exit. Set to 0 to keep them forever. |
| `SERVER_NAME`           | `Valheim Server` | Valheim server name (shown in the community list).                                      |
| `SERVER_PASSWORD`       | ``               | Password to protect the server.                                                         |
| `SERVER_PORT`           | `2456`           | First port of the three UDP ports used by the server.                                   |
| `SERVER_PUBLIC`         | `0`              | Wether the server should be public or not. `0` -> private, `1` -> public                |
| `SERVER_WORLD_NAME`     | `world`          | Name of the world.                                                                      |

### Persistence

By default the saves are located in `/valheim/saves`. You might want to add a volume to that location.

## Helm chart

A chart is provided to deploy within kubernetes.

### Install

```sh
git clone [REPO_CLONE_URL] && cd valheim
helm install --set [OPTION] [RELEASE] chart
```

> Make sure to replace the `[...]` accordingly.

> You may also use a `values.yaml` file using `helm install -f [FILE] ...`

### Upgrade

```sh
git clone [REPO_CLONE_URL] && cd valheim
helm upgrade --reuse-values --set [OPTION] [RELEASE] chart
```

### Uninstall

```sh
helm uninstall [RELEASE]
```

### Chart parameters

#### Common parameters

| Name                          | Description                                                                             | Value                           |
| ----------------------------- | --------------------------------------------------------------------------------------- | ------------------------------- |
| `image.tag`                   | Image version                                                                           | `""`. Defaults to `appVersion`. |
| `persistence.enabled`         | Enable persistence                                                                      | `yes`                           |
| `persistence.size`            | Claim volume size                                                                       | `1Gi`                           |
| `persistence.storageClass`    | Storage class to use. Do not set to use the default class.                              | `-`                             |
| `server.backup.directory`     | Location of the backups.                                                                | `"saves/backups"`               |
| `server.backup.enabled`       | Wether to create a backup on exit or not.                                               | `yes`                           |
| `server.backup.retention_days`| Backups older than this value will be removed upon exit. Set to 0 to keep them forever. | `30`                            |
| `server.name`                 | Valheim server name (shown in the community list).                                      | `""`. Defaults to `world` name. |
| `server.password`             | Password to protect the server.                                                         | `"password"`                    |
| `server.public`               | Wether the server should be public or not.                                              | `yes`                           |
| `server.world`                | Name of the world.                                                                      | `"world"`                       |

#### Extended parameters

| Name                            | Description                                                                            | Value                               |
| ------------------------------- | -------------------------------------------------------------------------------------- | ----------------------------------- |
| `affinity`                      | Pod affinities                                                                         | `{}`                                |
| `fullnameOverride`              | Override the full name of the resources                                                | `""`                                |
| `image.pullPolicy`              | Image pull policy                                                                      | `IfNotPresent`                      |
| `image.repository`              | Use this if the cronjob api has a different version in your cluster                    | `nox404/valheim`                    |
| `imagePullSecrets`              | Specify image pull secrets                                                             | `[]`                                |
| `nameOverride`                  | Override the chart's name                                                              | `""`                                |
| `nodeSelector`                  | Constrain the pod to specific nodes                                                    | `{}`                                |
| `persistence.annotations`       | Add annotations to the persitent volume claim                                          | `{ helm.sh/resource-policy: keep }` |
| `persistence.existingClaim`     | Use an existing claim                                                                  | `""`                                |
| `podAnnotations`                | Extra pod annotations                                                                  | `{}`                                |
| `podSecurityContext`            | The pod security context                                                               | `{}`                                |
| `resources`                     | Specify container resources                                                            | `{}`                                |
| `securityContext`               | The container security context                                                         | `{}`                                |
| `service.nodePort`              | First port of the three for the service to open on the host when using NodePorts       | `""`                                |
| `service.port`                  | First port of the three for the service                                                | `2456`                              |
| `service.type`                  | Service type                                                                           | `ClusterIP`                         |
| `serviceAccount.annotations`    | Add annotations to the service account                                                 | `{}`                                |
| `serviceAccount.create`         | Wether to create a service account                                                     | `true`                              |
| `serviceAccount.name`           | Name of the service account to create and/or use                                       | `""`. Defaults to `chart-release`   |
| `terminationGracePeriodSeconds` | Time in seconds to wait upon terminating the container                                 | `60`                                |
| `tolerations`                   | Pod tolerations                                                                        | `[]`                                |
