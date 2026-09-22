# Bedrock WordPress image to test charts/wordpress against, with
# WP-CLI. See docs/development/testing.md for how this is used.
#
# Not published anywhere and not meant for production use - the chart's
# image.repository/tag values are meant to point at your own Bedrock build.

FROM composer:2 AS build
WORKDIR /app
RUN composer create-project roots/bedrock . --no-interaction --no-dev --no-scripts \
    && composer clear-cache

FROM wordpress:php8.3-fpm-alpine
RUN apk add --no-cache mariadb-client \
    && curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && wp --info --allow-root

WORKDIR /var/www/html
RUN rm -rf /var/www/html/*
COPY --from=build --chown=www-data:www-data /app /var/www/html

# The base image's own docker-entrypoint.sh bootstraps a classic WordPress
# install into /var/www/html on every container start if it doesn't see a
# wp-settings.php there - which, with Bedrock's core under web/wp, it never
# does, so it silently re-copies a full classic WP tree alongside Bedrock's
# on every start. Skip it; Bedrock's structure is already complete.
ENTRYPOINT []
CMD ["php-fpm"]
