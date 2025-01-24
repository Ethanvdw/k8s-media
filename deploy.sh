#!/bin/bash
kubectl apply -f manifests/base/namespace.yaml
kubectl apply -f manifests/ -R
