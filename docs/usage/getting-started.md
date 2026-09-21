# Getting started

## Prerequisites

This chart does not install these for you:

1. **A WordPress image with a Bedrock layout.** The chart's `copy-wordpress` init container copies `image.repository:image.tag` into a shared volume and runs `chmod 444` on `web/wp-config.php`. It expects the image's WordPress source to live under `/var/www/html/web`, with `wp-config.php` at `web/wp-config.php` - the [Bedrock](https://roots.io/bedrock/) layout, not the classic `wp-admin`/`wp-content` layout the official `wordpress` Docker Hub image ships. `values.yaml`'s default `image.repository: wordpress` is a placeholder that will not boot correctly; you need your own Bedrock-based image (see [Image requirements](configuration.md#image-requirements)).
2. **A MariaDB/MySQL database**, reachable from the cluster, with credentials you provide via `env` (see [Database](configuration.md#database)).
3. **An S3-compatible bucket**, only if you use `dbBackup`, `fileBackup`, `dbImport`, or `fileImport` (see [Backups and imports](backups-and-imports.md)).

## Install

```bash
helm install my-wordpress oci://registry-1.docker.io/digitalist/wordpress --version <chart-version>
```

or, from a checkout of this repository:

```bash
helm install my-wordpress ./charts/wordpress -f my-values.yaml
```

A minimal `my-values.yaml` overriding just the database connection and image:

```yaml
image:
  repository: my-registry/my-bedrock-wordpress
  tag: latest

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

The `mariadb` Secret name/key shown as the chart's own default (`env[3].valueFromSecret`) is just that - a default. Point it at whatever Secret actually holds your database password; the Secret itself must already exist, this chart does not create it.

## Next steps

- [Configuration](configuration.md) - the values that need more explanation than a table gives, including the image and security-context requirements.
- [Backups and imports](backups-and-imports.md) - the S3-backed CronJobs/Jobs, and what they actually require from your image.
