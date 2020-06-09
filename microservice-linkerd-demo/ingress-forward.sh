#!/bin/sh
echo Open Ingress at http://localhost:31380/
kubectl port-forward deployment/traefik 31380:8000

