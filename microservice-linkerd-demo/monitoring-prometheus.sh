#!/bin/sh
echo Open Prometheus at http://localhost:9090/
kubectl -n linkerd port-forward deployment/linkerd-prometheus 9090:9090
