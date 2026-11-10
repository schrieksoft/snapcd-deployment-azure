helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm template istiod istio/istiod --version "1.30.3" --namespace istio-system --values values.yaml > generated.yaml
python3 ../strip-helm-labels.py generated.yaml