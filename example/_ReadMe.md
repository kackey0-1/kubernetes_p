
[deploy microservice apps by kustomization.yaml](https://github.com/GoogleCloudPlatform/microservices-demo/blob/master/docs/development-guide.md)

requirements

use argo rollout
use db connection
use kustomization.yaml)
- requirements 
  - use argo rollout
  - use db connection
  - use kustomization.yaml
 
```bash
# To launch Minikube (tested with Ubuntu Linux). Please, ensure that the local Kubernetes cluster has at least:
#
# 4 CPUs
# 4.0 GiB memory
# 32 GB disk space
minikube start --cpus=4 --memory 4096 --disk-size 32g
``` 

## deploy kubernetes cluster
```bash
kubectl apply -k example/
kubectl get pod,ro,svc,ing -o=wide
```
