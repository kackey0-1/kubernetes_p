# Try eksctl
- tool to manage EKS Cluster
- auto-creation of CloudFormation template
- auto-scaling of nodes

## Install EKS-CTL
```console
brew install weaveworks/tap/eksctl
brew upgrade eksctl && brew link --overwrite eksctl
eksctl version
```

## Create EKS Cluster
```console
eksctl create cluster \
--name eksctl-handson \
--region ap-northeast-1 \
--nodes 3 \
--nodes-min 3 \
--nodes-max 3 \
--node-type t2.medium \
--ssh-public-key eks_k-kakimoto
```

## Deploy Sample App
```
vi examples/guestbook/frontend-service.yaml
# type: NodePort     # comment-out
# typt: LoadBalancer # comment-in

kubectl apply -f examples/guestbook
```
