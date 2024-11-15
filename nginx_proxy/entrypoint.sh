#!/bin/sh

set -e

envsubst '$APP_HOST $APP_PORT $LISTEN_PORT' < /etc/nginx/conf.d/default.conf.tpl > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'