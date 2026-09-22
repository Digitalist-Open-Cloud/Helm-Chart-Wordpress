# Testing

Five CI workflows plus one local-only asset (`tests/`). All run on every push/PR to `main`.

## Render matrix (`render.yaml`)

For every file in `tests/render/*.yaml` plus `tests/kind/values.yaml`, runs `helm lint`, `helm template`, and validates the rendered output against upstream Kubernetes JSON schemas with [`kubeconform`](https://github.com/yannh/kubeconform). This is pure static validation - no cluster, no external images pulled beyond what `kubeconform`'s schema fetch needs.

Each `tests/render/*.yaml` file is a values combination chosen to exercise a distinct set of optional templates together:

| File | Exercises |
|---|---|
| `default.yaml` | Chart defaults, no overrides |
| `ingress-and-scaling.yaml` | Ingress + TLS, autoscaling/HPA, `LoadBalancer` service |
| `extras-and-sidecars.yaml` | Sidecars, extra secrets/configmap/volumes, `dotenv`, `wordpressEnvs`, `extraCronJobs`, Cavalcade |
| `backups-and-imports.yaml` | `dbBackup`/`fileBackup`/`dbImport`/`fileImport` all enabled together |
| `custom-config.yaml` | `customConfig` overrides for every config block, `externalConfigMap` |
| `components-disabled.yaml` | Optional components off, `wordpress.persistence.existingClaim` |

Run it locally:

```bash
for values in tests/render/*.yaml tests/kind/values.yaml; do
  helm lint charts/wordpress --values "$values"
  helm template wordpress charts/wordpress --values "$values" | kubeconform -strict -summary -schema-location default
done
```

When adding a values-driven template branch, add or extend a fixture here rather than only relying on the kind e2e test - it's near-instant and doesn't need a cluster or any external image.

## Schema drift (`schema.yaml`)

Fails if `charts/wordpress/values.schema.json` doesn't match what `helm-schema` would generate right now. Regenerate it (see [Contributing](contributing.md#regenerating-the-schema-and-docs)) after touching `values.yaml`, and commit the result.

## Security scan (`checkov.yaml`)

Runs [Checkov](https://www.checkov.io/) against the chart's default render. `charts/wordpress/.checkov.yaml` lists deliberate skips, each with a comment explaining why (a real chart constraint - e.g. a baked-in low uid - not just a check being inconvenient). Run locally:

```bash
checkov -d charts/wordpress --framework helm --config-file charts/wordpress/.checkov.yaml
```

If checkov reports a *new* failing check, fix the underlying template/values default first; only add it to the skip list if there's a genuine, documentable reason it can't be fixed (matching the existing skips' style).

## Spelling (`spelling.yaml`)

[`cspell`](https://cspell.org/) against the whole repo, configured by `cspell.json` + the word list in `.cspell/dictionary`. Run locally with `npx cspell "**/*"`. Add genuinely new technical terms to `.cspell/dictionary` (one per line, alphabetical) rather than sprinkling `cspell:ignore` comments.

## Live cluster (`kind-e2e.yaml`)

Boots a [kind](https://kind.sigs.k8s.io/) cluster and does a real `helm install`, then checks that the pod actually starts and serves traffic:

1. Builds the repo-root [`Dockerfile`](https://github.com/Digitalist-Open-Cloud/Helm-Chart-Wordpress/blob/main/Dockerfile) (cached via `docker/build-push-action`'s GitHub Actions cache backend, since `composer create-project` is network-heavy) and `kind load docker-image`s it. This is a *real* Bedrock WordPress build - `composer create-project roots/bedrock`, plus WP-CLI and a MariaDB client - not a placeholder string. Built and verified locally (real MariaDB, real `wp core install`, real `wp db export`/`mariadb -h` invocations matching the chart's actual `dbBackup`/`dbImport` commands) before being wired in here.
2. Installs a throwaway MariaDB (`tests/kind/mariadb.yaml`) and ingress-nginx.
3. `helm install`s the chart with `tests/kind/values.yaml` (points `env`/`image` at the fixtures above - including `WP_HOME`/`WP_SITEURL`, which Bedrock requires - and clears `wordpress.persistence.storageClass` so the PVC actually binds on kind's `local-path` provisioner instead of sitting `Pending` against the chart's `storageClassName: ""` default).
4. Waits for the Deployment's rollout, checks the PVC is `Bound`, then curls the pod both directly and through ingress-nginx, asserting a real WordPress response: a fresh, empty database makes WordPress redirect `/` to `/wp/wp-admin/install.php` with a `302`.

!!! note "What this does *not* cover"
    `dbBackup`/`fileBackup`/`dbImport`/`fileImport` (S3-backed) still aren't exercised live here. Live S3 integration testing was removed after two rounds of real trouble (MinIO's Docker Hub images being pulled entirely, then the replacement OOMKilling on default resource limits) made it too fragile for the value it added at the time - that's the remaining blocker, not the fixture image; the Bedrock build above already has the WP-CLI/MariaDB-client tooling `dbBackup`/`dbImport` need. Structural coverage - the chart renders valid manifests with all four enabled - still lives in `tests/render/backups-and-imports.yaml`. Live S3 e2e coverage is expected to come back once a real S3 bucket is available for the test to target, rather than another disposable in-cluster fixture.

If you need to debug a kind-e2e failure precisely, `docker run` the exact image/command locally rather than iterating on cluster runs - most of the real bugs found while building this suite (the nginx uid, the `chmod .../web/wp-config.php` layout mismatch, the mc/wp-cli tooling gaps) were found this way, against the *actual* images, faster and more conclusively than reasoning about Kubernetes YAML.

## Docs (`techdocs.yml`)

Publishes this site via Backstage TechDocs on every push. `mkdocs.yml` (repo root) defines the nav and theme; pages live under `docs/`.
