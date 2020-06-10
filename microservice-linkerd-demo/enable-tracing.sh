#!/bin/sh
linkerd upgrade --addon-config tracing.yaml | kubectl apply -f -
