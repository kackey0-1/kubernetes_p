# EKS Setup
## Create/Describe/Delete EKS Cluster

```bash
# Install necessary tools
brew install kubectl 
brew install helm
brew install awscli
brew install aws-iam-authenticator
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl

# Create Public Key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa.`date '+%Y-%m-%d'` -C kentaro.a.kakimoto@gmail.com

# Create EKS Cluster and Node
# マスターノード(AWS が管理, なのでEKSコンソールではマスターノードのEC2は見えない):
# - マスターノードのEC2が3つ冗長化
# - EC2のsecurity group
# - EC2のIAM role と instance profile
# ワーカーノード:
# - ユーザーが好きなだけ起動できる
# - auto scaling group (ASG)でスケールアップ・ダウンできる
# - ワーカーノードEC2のsecurity group
# - ワーカーノードEC2のIAM Role と Instance Profile
# AWS VPC:
# - VPC
# - ap-northeast-1 regionの3つのavailability zones (AZ) にPublicとPrivateのSubnets   
# - Route tablesとRoute
# - Internet Gateway
# - NAT gateway
eksctl create cluster \
    --name eks-from-eksctl \
    --version 1.16 \
    --region ap-northeast-1 \
    --nodegroup-name workers \
    --node-type t3.medium \
    --nodes 1 \
    --nodes-min 1 \
    --nodes-max 2 \
    --ssh-access \
    --ssh-public-key ~/.ssh/id_rsa.2020-11-05.pub \
    --managed

# Describe EKS Cluster 
aws eks describe-cluster --name eks-from-eksctl --region ap-northeast-1

# Delete EKS Cluster
eksctl delete cluster \
    --name eks-from-eksctl \
    --region ap-northeast-1
```

## Helm Chart
- KubernetesのYAMLリソース(pod, deployment, service)から変数を除外し、`values.yaml`にて一括管理
- 複数のKubernetesのYAMLリソース(pod, deployment, service)をバンドル化して、1つのArtifactであるChartとして管理

```bash
# Create Helm
helm create test
# Add Helm Repo 
helm repo add stable https://charts.helm.sh/stable
# Show Helm Repos
helm repo list
# Search stable resoures
helm search repo stable
# Update Helm Repo
helm repo update
# Search nginx in repo

```
