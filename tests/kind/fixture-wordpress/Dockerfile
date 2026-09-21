# e2e-only fixture image, built and loaded straight into the kind cluster
# (see .github/workflows/kind-e2e.yaml) - never pushed to a registry.
#
# The chart's copy-wordpress init container (templates/deployment.yaml) runs
# `chmod 444 /wordpress-app/web/wp-config.php`, assuming a bedrock-style
# layout (web/wp-config.php). The chart's own default image
# (wordpress:5.7-php7.4-fpm-alpine) is the vanilla Docker Hub image with the
# classic WordPress layout instead (wp-content/wp-admin directly under
# /var/www/html, no web/ dir, no wp-config.php at all), so the init
# container crash-loops against it. Real deployments of this chart clearly
# point image.repository/tag at a private bedrock+wp-cli image this repo
# doesn't have access to; this fixture adds just enough of that layout for
# the chart's own templates to work, so the e2e test exercises the chart
# rather than working around a placeholder default.
FROM wordpress:5.7-php7.4-fpm-alpine

RUN mkdir -p /var/www/html/web \
    && printf '<?php\n// e2e fixture wp-config.php - not a real WordPress config\n' > /var/www/html/web/wp-config.php \
    && printf '<?php\necho "wordpress e2e fixture ok";\n' > /var/www/html/web/index.php \
    && chown -R www-data:www-data /var/www/html/web
