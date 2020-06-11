#!/bin/sh
docker tag microservice-linkerd-apache gcr.io/${PROJECT_ID}/microservice-linkerd-apache
docker push gcr.io/${PROJECT_ID}/microservice-linkerd-apache
docker tag microservice-linkerd-postgres gcr.io/${PROJECT_ID}/microservice-linkerd-postgres
docker push gcr.io/${PROJECT_ID}/microservice-linkerd-postgres
docker tag microservice-linkerd-shipping:1 gcr.io/${PROJECT_ID}/microservice-linkerd-shipping:1
docker push gcr.io/${PROJECT_ID}/microservice-linkerd-shipping:1
docker tag microservice-linkerd-invoicing:1 gcr.io/${PROJECT_ID}/microservice-linkerd-invoicing:1
docker push gcr.io/${PROJECT_ID}/microservice-linkerd-invoicing:1
docker tag microservice-linkerd-order:1 gcr.io/${PROJECT_ID}/microservice-linkerd-order:1
docker push gcr.io/${PROJECT_ID}/microservice-linkerd-order:1
