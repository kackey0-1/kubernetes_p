## Check cluster state
```bash
# argo-rollouts
kubectl get pod,ro,svc,ing --namespace argo-rollouts
# default namespace
kubectl get pod,ro,svc,ing
```

## Apply Resources from a directory containing kustomization.yaml
```bash
kubectl apply -k dir/
```

## Install Argo Rollouts
```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml
```

## Deploy 
```bash
kubectl apply -f argocd/ --validate=false
kubectl get pod,ro,svc,ing -o=wide
kubectl delete -f argocd/
```
