# Contributing to the chart

## Repository layout

```
charts/wordpress/
  Chart.yaml            # name, version, appVersion
  values.yaml            # all defaults, documented with helm-docs/helm-schema comment conventions
  values.schema.json      # generated - see "Schema" below, never hand-edit
  README.md              # generated - see "Values docs" below, never hand-edit
  .checkov.yaml           # security-scan skip list, each entry justified in a comment
  templates/
tests/
  render/*.yaml           # values combinations for lint/template/kubeconform (see testing.md)
  kind/                   # fixtures + values for the live kind e2e test
.github/workflows/        # CI - see testing.md for what each one does
docs/                      # this site (TechDocs/mkdocs)
```

## `values.yaml` comment conventions

This chart uses [`helm-schema`](https://github.com/dadav/helm-schema) (`--helm-docs-compatibility-mode`) to generate `values.schema.json`, and [`helm-docs`](https://github.com/norwoodj/helm-docs) to generate `README.md`'s values table. Both read comments directly above a key:

- `# -- Some description` (note the `--`) becomes that key's description in both the schema and the README table.
- A `# @schema` ... `# @schema` block (YAML, between the two markers) sets explicit JSON Schema keywords for that key - most commonly `additionalProperties: true` for free-form maps (`extraSecrets.data`, `wordpressEnvs`, `nodeSelector`, ...), since `values.yaml` only lists keys that are literally present, and an empty `{}` default would otherwise reject any real-world key a user adds.

!!! warning "helm-schema comment quirk"
    A plain (non-`@schema`, non-`# --`) comment placed directly above certain keys - confirmed on `nginx.securityContext.runAsUser` - makes `helm-schema` drop the inferred `type` and coerce the default to a string, even with a one-word comment. Reproduce before assuming a fix works: run the regen command below and diff the affected key. The workaround is an explicit `# @schema` block pinning `type: <the real type>` above the description, which is now the pattern used in `values.yaml` wherever this bit.

Existing multi-line commented-out YAML examples (`# extraVolumes:\n# - name: ...`) already trigger a milder version of this - the generated `description` ends up garbled, only capturing the comment block's last line or two. This is cosmetic (it doesn't affect what values pass validation) and already present throughout `values.yaml`; it isn't worth fighting for every field, but don't be surprised by it.

## Regenerating the schema and docs

Both are checked in CI (`schema.yaml` fails the build if `values.schema.json` is stale; nothing currently re-checks `README.md`, so regenerate it by habit after touching `values.yaml`):

```bash
# values.schema.json
helm-schema --chart-search-root charts/wordpress \
  --helm-docs-compatibility-mode --no-dependencies \
  --skip-auto-generation required

# charts/wordpress/README.md
helm-docs --chart-search-root charts/wordpress
```

## Adding a template

Match the existing conventions:

- Labels via `{{- include "wordpress.labels" . | nindent 4 }}` (or `$` inside a `range`).
- Resource names via `{{ include "wordpress.fullname" . }}-<suffix>`.
- If the resource needs the database `env` list, reuse `.Values.env` verbatim (the `valueFromSecret`/`value` branching pattern is repeated in every Job/CronJob template - copy it rather than re-deriving it).
- Set `resources`, `securityContext`, and (at the pod level) `securityContext`/`podSecurityContext` explicitly - don't leave them unset. Checkov (see below) will fail a container missing these, and getting them right the first time is cheaper than a follow-up permissions bug (see the nginx uid story in [Configuration](../usage/configuration.md#security-context-and-uids) for what "cheaper" is relative to).
- A standalone Job/CronJob container running `image.repository:image.tag` does **not** need the `copy-wordpress` init-container/`wordpress-app` emptyDir dance the main Deployment uses - that dance exists purely to share one copy of the WordPress source between the Deployment's sibling php-fpm/nginx/Cavalcade containers. A lone container already has the image's own `/var/www/html` filesystem.

## Releasing

1. Bump `charts/wordpress/Chart.yaml`'s `version` (and `appVersion` if the underlying WordPress version target changed).
2. Regenerate the schema and README (above) if `values.yaml` changed since the last bump.
3. `.github/workflows/oci.yaml` packages and pushes the chart to Docker Hub and the internal registry on tag push.

## Chart-level caveats worth knowing before changing things

- **The default `image` is a placeholder**, not a working install - see [Image requirements](../usage/configuration.md#image-requirements). Don't "fix" the init container's `chmod .../web/wp-config.php` to tolerate a classic-layout image; the chart is Bedrock-only by design (per the root `README.md`).
- **`nginx.securityContext.runAsUser` must match whatever uid the nginx image's `/var/lib/nginx` directories are owned by.** It's `65532` for `digitalist/nginx`; changing the image without re-checking this uid reintroduces the exact permission-denied bug that was already shipped and fixed once.
- **`dbBackup`/`dbImport` need WP-CLI and a MySQL client in the image**; the default image has neither. `dbImport`'s Job intentionally never fails the install (`|| true; exit 0`) even when the import itself failed - don't "fix" that without checking why it was made non-fatal first (git history: "fix for db import, exit true").
- **`fileImport` writes to a `mirror/` staging subpath**, not the live `uploads` path the app serves from - see [Backups and imports](../usage/backups-and-imports.md#fileimport-writes-to-a-staging-path-not-the-live-uploads-directory). This may be intentional (a manual-promotion staging area) rather than a bug; don't silently redirect it into the live path without confirming which is intended.
