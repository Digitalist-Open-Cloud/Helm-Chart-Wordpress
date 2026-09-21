# Backups and imports

Four independent, optional features, all talking to an S3-compatible bucket through [MinIO's `mc` client](https://min.io/docs/minio/linux/reference/minio-mc.html), downloaded at runtime from `minioClientDownload` (default: `https://dl.min.io/aistor/mc/release/linux-amd64/mc`):

| Value | Kind | Trigger | Purpose |
|---|---|---|---|
| `dbBackup` | CronJob | schedule | Exports the database with `wp db export`, uploads to S3 |
| `fileBackup` | CronJob | schedule | Mirrors the live uploads directory to S3 with `mc mirror` |
| `dbImport` | Job (post-install hook) | fresh `helm install` only | Downloads a `.sql` dump from S3, imports with the `mariadb`/`mysql` CLI |
| `fileImport` | Job (post-install hook) | fresh `helm install` only | Downloads a bucket's contents from S3 to a PVC path |

All four need a Secret named exactly `s3-storage` in the release namespace, with keys `S3_URL`, `S3_ACCESS_KEY`, `S3_SECRET_KEY` - not created by this chart:

```bash
kubectl create secret generic s3-storage \
  --from-literal=S3_URL=https://s3.example.com \
  --from-literal=S3_ACCESS_KEY=... \
  --from-literal=S3_SECRET_KEY=...
```

## `dbBackup`/`dbImport` need WP-CLI and a MySQL client

`dbBackup`'s CronJob runs `wp db export` and `wp db tables --all-tables-with-prefix`; `dbImport`'s Job pipes a `.sql` file into the `mariadb` CLI. Neither `wp` nor a `mariadb`/`mysql` client ships in the chart's default `image` (confirmed by inspecting it directly - only `curl` is present). If your image doesn't have both, `dbBackup` fails outright, and **`dbImport` fails silently**: its script wraps the import in `|| true` and always `exit 0`s, so a broken import still shows as a successful post-install hook. Check the Job's logs, not just its exit status, after enabling `dbImport`.

`fileBackup` and `fileImport` only need `curl` (to fetch `mc`) plus generic shell tools, so they work against the chart's default image.

## `fileImport` writes to a staging path, not the live uploads directory

`fileImport.path` defaults to `/var/www/html/web/app/mirror/uploads`. The Job mounts the same PVC as the main Deployment, but at its **root**, not at the `uploads` subPath the running WordPress pod serves from - so an import lands under `<pvc-root>/mirror/uploads/`, a sibling directory of the live `<pvc-root>/uploads/` the app actually reads. Files imported this way are on the volume, but not automatically visible to WordPress; promoting them to the live path is a manual step (or override `fileImport.path` to point directly at `uploads` if that staging behavior isn't what you want).

## Buckets and paths

`dbBackup.bucket`/`fileBackup.bucket` are plain bucket names. `dbImport.bucket` and `fileImport.bucket` can include a path prefix (e.g. `"wordpress-backups/foo/is/bar"`, no trailing slash) - the chart concatenates it directly into the `mc` object path, so check the actual command in `templates/job-db-import.yaml`/`templates/job-file-import.yaml` if an import can't find its object.

`dbBackup`/`fileBackup` both support an optional `retentionDays`, applied as `mc rm --recursive --force --older-than <n>d` against the bucket (or `bucket/files/<prefix>` for `fileBackup`) after each successful run.
