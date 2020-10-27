# EKS Service

## Create Service-Role
```bash
# create role on AWS IAM
aws iam create-role --role-name eksServiceRole --assume-role-policy-document file://eks_iam_role-trust-policy.json

# attach policy for created role
aws iam attach-role-policy --role-name eksServiceRole --policy-arn "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
aws iam attach-role-policy --role-name eksServiceRole --policy-arn "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"

# export environment variables
export EKS_SERVICE_ROLE=`aws iam get-role --role-name eksServiceRole --query "Role.Arn" --output text`
```

## Create VPC by Cloudformation
```
# Create Stack
aws cloudformation create-stack --stack-name eks-vpc --template-url https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2018-11-07/amazon-eks-vpc-sample.yaml

# export environment variables
export SECURITY_GROUPS=`aws cloudformation describe-stacks --stack-name eks-vpc --query "Stacks[0].Outputs[?OutputKey=='SecurityGroups'].OutputValue | [0]" --output text`
export VPC_ID=`aws cloudformation describe-stacks --stack-name eks-vpc --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue | [0]" --output text`
export SUBNET_IDS=`aws cloudformation describe-stacks --stack-name eks-vpc --query "Stacks[0].Outputs[?OutputKey=='SubnetIds'].OutputValue | [0]" --output text`
```

## Create EKS Cluster
```
aws eks create-cluster --name eks-handson --role-arn $EKS_SERVICE_ROLE --resources-vpc-config subnetIds=$SUBNET_IDS,securityGroupIds=$SECURITY_GROUPS

# Check Status of EKS
aws eks describe-cluster --name eks-handson --query cluster.status
```

## kubectlのEKS用configファイルを作成
```
aws eks update-kubeconfig --name eks-handson

# 動作確認
kubectl get all
```

## Create Node by cloudformation
```
aws cloudformation create-stack --stack-name eks-handson-workernodes --template-url https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2018-11-07/amazon-eks-nodegroup.yaml --parameters ParameterKey=KeyName,ParameterValue=eks_k-kakimoto ParameterKey=NodeImageId,ParameterValue=ami-07fdc9272ce5b0ce5 ParameterKey=NodeInstanceType,ParameterValue=t2.small ParameterKey=NodeAutoScalingGroupMinSize,ParameterValue=2 ParameterKey=NodeAutoScalingGroupMaxSize,ParameterValue=3 ParameterKey=NodeVolumeSize,ParameterValue=10 ParameterKey=ClusterName,ParameterValue=eks-handson ParameterKey=NodeGroupName,ParameterValue=eks-handson-node-group  ParameterKey=ClusterControlPlaneSecurityGroup,ParameterValue=$SECURITY_GROUPS ParameterKey=VpcId,ParameterValue=$VPC_ID ParameterKey=Subnets,ParameterValue=$SUBNET_IDS --capabilities CAPABILITY_IAM
aws cloudformation create-stack --stack-name eks-handson-workernodes --template-url https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2018-11-07/amazon-eks-nodegroup.yaml --parameters ParameterKey=KeyName,ParameterValue=eks_k-kakimoto ParameterKey=NodeImageId,ParameterValue=ami-07fdc9272ce5b0ce5 ParameterKey=NodeInstanceType,ParameterValue=t2.small ParameterKey=NodeAutoScalingGroupMinSize,ParameterValue=2 ParameterKey=NodeAutoScalingGroupMaxSize,ParameterValue=3 ParameterKey=NodeVolumeSize,ParameterValue=10 ParameterKey=ClusterName,ParameterValue=eks-handson ParameterKey=NodeGroupName,ParameterValue=eks-handson-node-group  ParameterKey=ClusterControlPlaneSecurityGroup,ParameterValue=$SECURITY_GROUPS ParameterKey=VpcId,ParameterValue=$VPC_ID ParameterKey=Subnets,ParameterValue='subnet-068e7b2c8e5bed678\,subnet-032bae3c8f98d27f6\,subnet-0fd3bb2dc528cddb5' --capabilities CAPABILITY_IAM
```

## Concat Node & EKS
```
# Get Instance Role
aws cloudformation describe-stacks --stack-name eks-handson-workernodes --query "Stacks[0].Outputs[?OutputKey=='NodeInstanceRole'].OutputValue | [0]" --output text

# Create ConfigMap for concatting EKS & NODE
curl -O https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2018-11-07/aws-auth-cm.yaml
```

## Concat Node&EKS
```
# Apply ConfigMap
kubectl apply -f aws-auth-cm.yaml

# Check Status
kubectl get nodes
```

## Sample App Deploy
```
vi example/guestbook/frontend-service.yaml
# type: NodePort // comment-out
# type: LoadBalancer // comment-in

# Deploy
kubectl apply -f examples/guestbook/

# Status Check
kubectl get all
```

## Delete Created Instance
```
kubectl delete -f example/guestbook/

# check deleted
kubectl get all

# delete stack, EKS Cluster
aws cloudformation delete-stack --stack-name eks-handson-workernodes
aws eks delete-cluster --name eks-handson
aws cloudformation delete-stack --stack-name eks-vpc
```

## Change kubectl context
```
# show context 
kubectl config get-contexts

# back to desktop context
kubectl config use-context docker-for-desktop

# delete EKS context
kubectl config delete-context arn:aws:...:cluster/eks-handson
```