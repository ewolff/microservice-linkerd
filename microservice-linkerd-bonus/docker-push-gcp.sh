#!/bin/sh
docker tag microservice-linkerd-demo gcr.io/${PROJECT_ID}/microservice-linkerd-demo
docker push gcr.io/${PROJECT_ID}/microservice-linkerd-demo
