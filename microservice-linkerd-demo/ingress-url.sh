#!/bin/sh
IP=$(kubectl get service traefik -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') 
PORT=$(kubectl get service traefik -o jsonpath='{.spec.ports[?(@.name=="web")].port}')
echo http://$IP:$PORT/
