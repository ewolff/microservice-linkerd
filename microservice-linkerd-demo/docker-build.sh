#!/bin/sh
docker build --tag=microservice-linkerd-apache apache
docker build --tag=microservice-linkerd-postgres postgres
docker build --tag=microservice-linkerd-shipping:1 microservice-linkerd-shipping
docker build --tag=microservice-linkerd-invoicing:1 microservice-linkerd-invoicing
docker build --tag=microservice-linkerd-order:1 microservice-linkerd-order
