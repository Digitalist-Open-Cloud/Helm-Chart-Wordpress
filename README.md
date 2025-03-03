# WordPress PHP-FPM Nginx Helm Chart

Run Bedrock Wordpress with php-fpm.

Any container should work, WordPress need be in path `/var/www/html/web`.

## Configuring Environment Variables

To set environment variables:

Use `valueFromSecret` to populate from a Secret:

```yaml
env:
- name: SECRET_VAR
    valueFromSecret:
    secretName: my-secret
    key: secret-key
```

Use value for plain variable values:

```yaml
env:
  - name: PLAIN_VAR
    value: "default-value"
```

Secrets must be created outside of the chart.

## Database

No database included in chart, that needs to be installed first.
Secret needed for database password, defaults to:

```yaml
  - name: DB_PASSWORD
    valueFromSecret:
      secretName: mariadb
      key: password
```

## Fork

This is forked from <https://github.com/fiveoclock/WordPress-Nginx-Helm-Chart>.
