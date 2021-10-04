#!/bin/bash

set -e

if [ "$ENVIRONMENT" == "docker-compose" ]; then
    export FLASK_SERVER_ADDR="flask:5000"
elif [ "$ENVIRONMENT" == "kube" ]; then
    export FLASK_SERVER_ADDR="backend.backend:5000"
else
    echo "ERROR | Unknown environment: $ENVIRONMENT - Exiting..."
    exit 1
fi

envsubst '$FLASK_SERVER_ADDR' < /tmp/default.conf > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
