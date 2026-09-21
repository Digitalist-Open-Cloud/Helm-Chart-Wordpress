# Helm Chart for WordPress

A Helm chart that runs [Bedrock](https://roots.io/bedrock/)-style WordPress with php-fpm and nginx as separate containers in one pod, plus optional S3-backed database/file backup and import jobs, and extra scheduled jobs.

This documentation has two audiences:

- **[Using the chart](usage/getting-started.md)** - you're deploying WordPress with this chart and need to know what to configure.
- **[Developing the chart](development/contributing.md)** - you're changing chart templates or values and need to know the repo's conventions and how its test suite works.

## What this chart is not

It does not install WordPress source, MariaDB, or an S3 bucket for you - those are prerequisites. See [Getting started](usage/getting-started.md) for what to bring.

## Values reference

Every value with its type and default is generated from `values.yaml` by [helm-docs](https://github.com/norwoodj/helm-docs) into [`charts/wordpress/README.md`](https://github.com/Digitalist-Open-Cloud/Helm-Chart-Wordpress/blob/main/charts/wordpress/README.md). The [Configuration](usage/configuration.md) page here explains the values that need more context than a table can give.
