#!/bin/bash

HELM_CHART_VERSION="1.30.3"
NAMESPACE="istio-gateway"

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm template istio-gateway istio/gateway --version "$HELM_CHART_VERSION" --namespace "$NAMESPACE" --values values/public-values.yaml > generated-public.yaml
python3 ../strip-helm-labels.py generated-public.yaml
