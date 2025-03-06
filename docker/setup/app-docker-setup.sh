#!/usr/bin/env bash

set -o errexit

export DEBIAN_FRONTEND=noninteractive

PHP_XHPROF_VERSION=2.3.10

PARENT_DIR="$(dirname "$(readlink -f "$0")")"

apt_install_php_runtime() {
  apt-get -qq install -y --no-install-recommends \
    zip \
    unzip \
    zlib1g-dev \
    libzip-dev
}

setup_php_configs() {
  mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
  ln -s /usr/local/bin/php /usr/bin/php

  cp "$PARENT_DIR/10-xhprof.ini" "$PHP_INI_DIR/conf.d/"
}

setup_php_extensions() {
  docker-php-ext-install "-j$(nproc)" pdo_mysql
  docker-php-ext-install "-j$(nproc)" zip

  pecl install "xhprof-$PHP_XHPROF_VERSION"
  docker-php-ext-enable xhprof
}

apt_clear_cache() {
  apt-get -qq clean
  rm -rf /var/lib/apt/lists/*
  truncate -s 0 /var/log/*log
}

apt-get -qq update
apt_install_php_runtime
setup_php_configs
setup_php_extensions
apt_clear_cache

# Remove this script
rm "$(readlink -f "$0")"
