# Deploy Web Application in k8s cluster

## Architecher According `docker-compose-k8s.yaml`
- Voting Pod
  - Deployment
    - container_port: 80
    - image: dockersamples/examplevotingapp_vote:before
    - replica: 2
- Voting Service
  - service_port: 5000
  - target_port: 80
  - service_type: NodePort
- Result Pod
  - Deployment
    - container_port: 80
    - image: dockersamples/examplevotingapp_result:before
    - replica: 1
- Result Service
  - service_port: 5001
  - target_port: 80
  - service_type: NodePort
- DB Pod
  - Deployment
    - container_port: 5432
    - image: postgres:9.4
    - replica: 1
    - environment
      - POSTGRES_USER: "postgres"
      - POSTGRES_PASSWORD: "postgres"
- DB Service
  - service_port: 5432
  - target_port: 5432
  - service_type: ClusterIP # DBは外部には公開すべきでない(Securityの安全性を担保するため)
- Redis Pod
  - Deployment
    - container_port: 6379
    - image: redis:alpine
    - replica 1
- Redis Service
  - service_port: 6379
  - target_port: 6379
  - service_type: ClusterIP # DBは外部には公開すべきでない(Securityの安全性を担保するため)
- Worker Pod
  - Deployment
    - image: dockersamples/examplevotingapp_worker
    - replica: 1
- Ingress ingress
  - /vote -> voting service of port 5000
  - /result -> result service of port 5001

```bash
# create deployment
kubectl create deployment vote --image dockersamples/examplevotingapp_vote:before --dry-run -o yaml > vote_deployment.yaml
kubectl create deployment result --image dockersamples/examplevotingapp_result:before --dry-run -o yaml > result_deployment.yaml
kubectl create deployment db --image postgres:9.4 --dry-run -o yaml > db_deployment.yaml
kubectl create deployment redis --image redis:alpine --dry-run -o yaml > redis_deployment.yaml
# create service
kubectl expose deployments.app/vote --type NodePort --port=5000 --target-port=80 --name=vote-nodeport --dry-run=client -o yaml > vote_service.yaml
kubectl expose deployments.app/result --type NodePort --port=5001 --target-port=80 --name=result-nodeport --dry-run=client -o yaml > result_service.yaml
kubectl expose deployments.app/db --type ClusterIP --port=5432 --target-port=5432 --name=result-nodeport --dry-run=client -o yaml > db_service.yaml
kubectl expose deployments.app/db --type ClusterIP --port=6379 --target-port=6379 --name=result-nodeport --dry-run=client -o yaml > redis_service.yaml
# create ingress

# apply deployment
kubectl apply -f vote_deployment.yaml 
kubectl apply -f result_deployment.yaml
kubectl apply -f db_deployment.yaml
kubectl apply -f redis_deployment.yaml
# apply service
kubectl apply -f vote_service.yaml
kubectl apply -f result_service.yaml
kubectl apply -f db_service.yaml
kubectl apply -f redis_service.yaml
```