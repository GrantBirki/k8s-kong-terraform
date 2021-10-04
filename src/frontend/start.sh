#!/bin/bash

set -e

if [ "$ENVIRONMENT_CONTEXT" == "docker-compose" ]; then
    export BACKEND_ADDR="backend:5000"
elif [ "$ENVIRONMENT_CONTEXT" == "kube" ]; then
    export BACKEND_ADDR="backend.backend:5000"
else
    echo "ERROR | Unknown ENVIRONMENT_CONTEXT: $ENVIRONMENT_CONTEXT - Exiting..."
    exit 1
fi

envsubst '$BACKEND_ADDR' < /tmp/default.conf > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
