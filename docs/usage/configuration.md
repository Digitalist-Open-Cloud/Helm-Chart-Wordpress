# Configuration

This page covers the values that need more context than the [generated values table](https://github.com/Digitalist-Open-Cloud/Helm-Chart-Wordpress/blob/main/charts/wordpress/README.md) can give. For backup/import-specific values, see [Backups and imports](backups-and-imports.md).

## Image requirements

`image.repository`/`image.tag` must point at a [Bedrock](https://roots.io/bedrock/)-style WordPress image:

- WordPress source (including `wp-config.php`) lives under `/var/www/html/web`, not directly under `/var/www/html`.
- The image's file ownership must work under uid `82`/gid `82` (see [Security context and uids](#security-context-and-uids)).

If you also use [`dbBackup` or `dbImport`](backups-and-imports.md#dbbackupdbimport-need-wp-cli-and-a-mysql-client), the image additionally needs `wp` (WP-CLI) and a `mariadb`/`mysql` client binary.

The chart's own default (`image.repository: wordpress`, the official Docker Hub image) does **not** meet any of this - it's a placeholder. Point `image` at your own image before installing.

## Database

The chart has no `db.*` values block; you configure the database purely through `env`, using the container's actual env var names:

```yaml
env:
  - name: DB_HOST
    value: my-mariadb.my-namespace.svc.cluster.local
  - name: DB_NAME
    value: wordpress
  - name: DB_USER
    value: wordpress
  - name: DB_PASSWORD
    valueFromSecret:
      secretName: my-mariadb-secret
      key: password
  - name: DB_PREFIX
    value: wp_
```

Each entry is either a plain `value`, or a `valueFromSecret` (`secretName` + `key`), which becomes a `secretKeyRef`. The Secret referenced by `valueFromSecret` must already exist - this chart never creates database Secrets.

This same `env` list is reused verbatim by every CronJob/Job the chart creates (`dbBackup`, `dbImport`, `extraCronJobs`), so changing it here changes the database credentials everywhere consistently.

## Security context and uids

Two different uids are load-bearing and must not be changed casually:

- **`podSecurityContext.runAsUser: 82`** (and `runAsGroup`/`fsGroup: 82`) - the wordpress/php-fpm container's uid. This is baked into the WordPress image's own file ownership; changing it breaks file permissions on the copied WordPress source and the uploads volume.
- **`nginx.securityContext.runAsUser: 65532`** - the `digitalist/nginx` image's own `nonroot` user, which owns its pre-created `/var/lib/nginx/{logs,tmp,html}` directories. Any other uid gets `Permission denied` opening nginx's default error log and pid file at container startup - this was a real, previously-shipped bug in this chart (it briefly defaulted to uid `100`), fixed after being reproduced against the actual image.

If you swap out `nginx.repository`/`nginx.tag` for a different image, re-check what uid *that* image's directories are owned by; don't assume `65532` transfers.

## nginx and PHP configuration

`customConfig` overrides the generated ConfigMap's four config blocks wholesale (not merged) - `php_fpm`, `php_opcache`, `php`, and `nginx_conf`. Leave a key `""` (the default) to keep the chart's built-in config for that block.

`externalConfigMap.enabled: true` with `externalConfigMap.name` replaces the entire generated ConfigMap with one you manage yourself, mounted at the same paths. Useful if `customConfig`'s all-or-nothing per-block overrides aren't granular enough.

The built-in `nginx_conf` assumes the Bedrock URL layout (`/wp/wp-admin`, `/wp/wp-content`, etc. rewritten from `/wp-admin`, `/wp-content`) and includes a GeoIP2 module load (`ngx_http_geoip2_module.so`) and an MaxMind `GeoLite2-Country.mmdb` lookup - both must exist in whatever nginx image you use, at the paths the config expects.

## Persistence

`wordpress.persistence.storageClass` has three states, matching the common Helm chart convention:

- unset/`null` - no `storageClassName` on the PVC; the cluster's default StorageClass provisions it.
- `"-"` (the chart's default) - `storageClassName: ""`; **disables dynamic provisioning**. Only binds to a PV that already exists with an empty storage class. On a cluster without such a PV pre-provisioned, the PVC stays `Pending` forever.
- any other string - that StorageClass name.

If your cluster provisions storage dynamically (the common case), override `storageClass: ""` (empty, not `"-"`) rather than relying on the default.

`wordpress.persistence.existingClaim` reuses an existing PVC instead of creating one; when set, the chart's own `pvc.yaml` isn't rendered at all.

## dotenv and wordpressEnvs

- `dotenv.enabled: true` mounts a Secret named `dotenv.name` as `/var/www/html/.env` on every WordPress-facing container (php-fpm, nginx, Cavalcade if enabled). The Secret itself isn't created by this chart.
- `wordpressEnvs` creates one ConfigMap per key, mounted at `/var/www/html/config/environments/<key>.php` - Bedrock's per-environment override mechanism (`staging.php`, `development.php`, etc).

## Extending the pod

- `sidecars` - arbitrary additional containers in the main Deployment's pod, each with its own `image`, `env`, `volumeMounts`, `resources`, probes and ports.
- `extraVolumes`/`extraVolumeMounts` - added to the pod/main container alongside the chart's own volumes.
- `extraSecrets`/`extraConfigMap` - chart-managed Secret/ConfigMap (`create: true`, `data: {<key>: <base64 or literal>}`), typically referenced from `extraVolumes`.
- `cavalcade.enabled: true` - adds the [Cavalcade](https://github.com/humanmade/Cavalcade) cron-runner sidecar (requires the Cavalcade plugin installed in WordPress).

## extraCronJobs

Additional CronJobs that run the chart's own `image.repository:image.tag` (not a separate image), for scheduled commands like WP-CLI maintenance tasks:

```yaml
extraCronJobs:
  - name: clear-expired-transients
    schedule: "0 4 * * *"
    command:
      - wp
      - transient
      - delete-expired
      - --allow-root
```

Each entry gets its own CronJob named `<release>-<name>`, using the chart's `env` (database credentials), `dotenv`/`wordpressEnvs` volumes, `resources`, and `securityContext`/`podSecurityContext` - the same environment the main WordPress container runs in, just without the nginx sidecar. `name` must be a valid Kubernetes resource name and unique within the list.
