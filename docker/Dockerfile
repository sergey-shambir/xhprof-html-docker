FROM php:8.3-fpm

# Suppress Node update notifications
ENV NO_UPDATE_NOTIFIER=true

ADD setup/ /setup/
RUN /setup/app-docker-setup.sh

WORKDIR /var/www
