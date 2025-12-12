# wordpress

![Version: 0.2.57](https://img.shields.io/badge/Version-0.2.57-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

A Helm chart to deploy WordPress in Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| cavalcade.enabled | bool | `false` |  |
| cavalcade.image | string | `"digitalist/cavalcade-docker:0.2"` |  |
| cavalcade.imagePullPolicy | string | `"Always"` |  |
| cavalcade.resources.limits.cpu | string | `"200m"` |  |
| cavalcade.resources.limits.memory | string | `"512Mi"` |  |
| cavalcade.resources.requests.cpu | string | `"25m"` |  |
| cavalcade.resources.requests.memory | string | `"64Mi"` |  |
| component | string | `""` |  |
| customConfig.nginx_conf | string | `""` |  |
| customConfig.php | string | `""` |  |
| customConfig.php_fpm | string | `""` |  |
| customConfig.php_opcache | string | `""` |  |
| dbBackup.bucket | string | `"wordpress-backups"` |  |
| dbBackup.enabled | bool | `false` |  |
| dbBackup.filenamePrefixOverride | string | `""` |  |
| dbBackup.retentionDays | int | `14` |  |
| dbBackup.schedule | string | `"0 2 * * *"` |  |
| dbImport.bucket | string | `"wordpress-backups/foo/is/bar"` |  |
| dbImport.enabled | bool | `false` |  |
| dbImport.file | string | `"db.sql"` |  |
| dbImport.path | string | `"uploads"` |  |
| dotenv.enabled | bool | `false` |  |
| dotenv.name | string | `"wordpress"` |  |
| env[0].name | string | `"DB_HOST"` |  |
| env[0].value | string | `"database.default.svc.cluster.local:3306"` |  |
| env[1].name | string | `"DB_NAME"` |  |
| env[1].value | string | `"db_wordpress"` |  |
| env[2].name | string | `"DB_USER"` |  |
| env[2].value | string | `"db_wordpress"` |  |
| env[3].name | string | `"DB_PASSWORD"` |  |
| env[3].valueFromSecret.key | string | `"password"` |  |
| env[3].valueFromSecret.secretName | string | `"mariadb"` |  |
| env[4].name | string | `"DB_PREFIX"` |  |
| env[4].value | string | `"wp_"` |  |
| externalConfigMap.enabled | bool | `false` |  |
| externalConfigMap.name | string | `""` |  |
| extraConfigMap.create | bool | `false` |  |
| extraConfigMap.data | object | `{}` |  |
| extraSecrets.create | bool | `false` |  |
| extraSecrets.data | object | `{}` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fileBackup.backupNamePrefixOverride | string | `""` |  |
| fileBackup.bucket | string | `"wordpress-backups"` |  |
| fileBackup.enabled | bool | `false` |  |
| fileBackup.path | string | `"/backup/uploads"` |  |
| fileBackup.retentionDays | int | `5` |  |
| fileBackup.schedule | string | `"30 2 * * *"` |  |
| fileImport.bucket | string | `"wordpress-files"` |  |
| fileImport.enabled | bool | `false` |  |
| fileImport.path | string | `"/var/www/html/web/app/mirror/uploads"` |  |
| fullnameOverride | string | `""` |  |
| helperImage | string | `"alpine:3.22"` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"wordpress"` |  |
| image.tag | string | `"5.7-php7.4-fpm-alpine"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.ingressClassName | string | `"nginx"` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.failureThreshold | int | `6` |  |
| livenessProbe.initialDelaySeconds | int | `10` |  |
| livenessProbe.periodSeconds | int | `20` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| minioClientDownload | string | `"https://dl.min.io/aistor/mc/release/linux-amd64/mc"` |  |
| nameOverride | string | `""` |  |
| nginx.pullPolicy | string | `"Always"` |  |
| nginx.repository | string | `"digitalist/nginx"` |  |
| nginx.resources.limits.cpu | string | `"200m"` |  |
| nginx.resources.limits.memory | string | `"256Mi"` |  |
| nginx.resources.requests.cpu | string | `"10m"` |  |
| nginx.resources.requests.memory | string | `"20Mi"` |  |
| nginx.stripPrefixes | list | `[]` |  |
| nginx.tag | string | `"1.21.6"` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext.fsGroup | int | `82` |  |
| podSecurityContext.runAsGroup | int | `82` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `82` |  |
| readinessProbe.enabled | bool | `true` |  |
| readinessProbe.failureThreshold | int | `6` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `20` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"200m"` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"25m"` |  |
| resources.requests.memory | string | `"64Mi"` |  |
| rolloutStrategy | string | `"Recreate"` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.privileged | bool | `false` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| sidecars | list | `[]` |  |
| tolerations | list | `[]` |  |
| wordpress.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| wordpress.persistence.annotations | object | `{}` |  |
| wordpress.persistence.enabled | bool | `true` |  |
| wordpress.persistence.labels | object | `{}` |  |
| wordpress.persistence.size | string | `"10Gi"` |  |
| wordpress.persistence.storageClass | string | `"-"` |  |
| wordpressEnvs | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
