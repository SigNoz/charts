# clickhouse

![Version: 16.0.5](https://img.shields.io/badge/Version-16.0.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 21.12.3.32](https://img.shields.io/badge/AppVersion-21.12.3.32-informational?style=flat-square)

A Helm chart for ClickHouse

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| signoz | <hello@signoz.io> | <https://signoz.io> |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | zookeeper | 7.0.5 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cloud | string | `nil` | Cloud service being deployed on (example: `aws`, `azure`, `gcp`, `other`). |
| zookeeper.enabled | bool | `true` | Please DO NOT override this value.    This chart installs Zookeeper separately.    Only if you know what you are doing, proceed with overriding. |
| zookeeper.autopurge.purgeInterval | int | `1` |  |
| zookeeper.fullnameOverride | string | `""` | Fullname override for zookeeper app |
| zookeeper.replicaCount | int | `1` | replica count for zookeeper |
| enabled | bool | `true` | Whether to install clickhouse. If false, `clickhouse.host` must be set |
| namespace | string | `nil` | Which namespace to install clickhouse and the `clickhouse-operator` to (defaults to namespace chart is installed to) |
| cluster | string | `"cluster"` | Clickhouse cluster |
| database | string | `"signoz_metrics"` | Clickhouse database |
| user | string | `"admin"` | Clickhouse user |
| password | string | `"27ff0399-0d3a-4bd8-919d-17c2181e6fb9"` | Clickhouse password |
| replicasCount | int | `1` | Clickhouse cluster replicas |
| shardsCount | int | `1` | Clickhouse cluster shards |
| image | object | `{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"yandex/clickhouse-server","tag":"21.12.3.32"}` | Clickhouse image |
| image.registry | string | `"docker.io"` | Clickhouse image registry to use. |
| image.repository | string | `"yandex/clickhouse-server"` | Clickhouse image repository to use. |
| image.tag | string | `"21.12.3.32"` | Clickhouse image tag.    Note: SigNoz does not support all versions of ClickHouse.    Please override the default only if you know what you are doing. |
| image.pullPolicy | string | `"IfNotPresent"` | Clickhouse image pull policy. |
| secure | bool | `false` | Whether to use TLS connection connecting to ClickHouse |
| verify | bool | `false` | Whether to verify TLS certificate on connection to ClickHouse |
| externalZookeeper | string | `nil` |  |
| servers | list | `[{"host":"signoz-zookeeper","port":2181},{"host":"signoz-zookeeper-2","port":2182},{"host":"signoz-zookeeper-3","port":2183}]` | URL for zookeeper. |
| tolerations | list | `[]` | Toleration labels for clickhouse pod assignment |
| affinity | object | `{}` | Affinity settings for clickhouse pod |
| nodeSelector | object | `{}` |  |
| resources | object | `{}` | Clickhouse resource requests/limits. See more at http://kubernetes.io/docs/user-guide/compute-resources/ |
| securityContext.enabled | bool | `true` |  |
| securityContext.runAsUser | int | `101` |  |
| securityContext.runAsGroup | int | `101` |  |
| securityContext.fsGroup | int | `101` |  |
| serviceType | string | `"ClusterIP"` | Service Type: LoadBalancer (allows external access) or NodePort (more secure, no extra cost) |
| persistence.enabled | bool | `true` | Enable data persistence using PVC. |
| persistence.existingClaim | string | `""` | Use a manually managed Persistent Volume and Claim.    If defined, PVC must be created manually before volume will be bound. |
| persistence.storageClass | string | `nil` | Persistent Volume Storage Class to use.    If defined, `storageClassName: <storageClass>`.    If set to `storageClassName: ""`, disables dynamic provisioning.    If undefined (the default) or set to `null`, no storageClassName spec is    set, choosing the default provisioner. |
| persistence.size | string | `"20Gi"` | Persistent Volume size |
| profiles | object | `{}` |  |
| defaultProfiles.default/allow_experimental_window_functions | string | `"1"` |  |
| coldStorage.enabled | bool | `false` |  |
| coldStorage.defaultKeepFreeSpaceBytes | int | `10485760` |  |
| coldStorage.endpoint | string | `"https://<bucket-name>.s3.amazonaws.com/data/"` |  |
| coldStorage.role.enabled | bool | `false` |  |
| coldStorage.role.annotations | object | `{}` |  |
| coldStorage.accessKey | string | `"<access_key_id>"` |  |
| coldStorage.secretAccess | string | `"<secret_access_key>"` |  |
| installCustomStorageClass | bool | `false` |  |
| clickhouseOperator.nodeSelector | object | `{}` |  |

