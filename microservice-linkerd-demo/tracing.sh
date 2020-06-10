#!/bin/sh
echo Open Jaeger at http://localhost:16686/
kubectl -n linkerd port-forward svc/linkerd-jaeger 16686
