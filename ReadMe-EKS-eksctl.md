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

## Install Dashboard
```
# apply pod for Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

# Get login token for dashboard
aws-iam-authenticator token -i eksctl-handson | jq -r '.status.token'

# Access dashboard via proxy
kubectl proxy --port=8000 --address='0.0.0.0' --disable-filter=true
# http://localhost:8000/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

# Logging to CloudWatchLogs by Kubernetes
logging will be std output by default Docker Container
logging will be json format by default
-> each node should have fluentd in pod and send logs to CloudWatch

```
# NodeのEC2に紐付いているIAM Roleの名前を取得
$ INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[].InstanceProfileName' | grep nodegroup)
$ ROLE_NAME=$(aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME | jq -r '.InstanceProfile.Roles[] | .RoleName')
# IAM Roleにログ収集用のインラインポリシーを追加
$ cat << "EoF" > ./k8s-logs-policy.json 
{
    "Version": "2012-10-17", 
    "Statement": [
        {
            "Action": [
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow"
        } 
    ]
}
EoF
$ aws iam put-role-policy --role-name $ROLE_NAME --policy-name Logs-Policy-For-Worker --policy-document file://k8s- logs-policy.json
```

## Deploy fluentd
```
# マニフェストファイルを取得
$ wget https://eksworkshop.com/logging/deploy.files/fluentd.yml
# クラスタ名を変更 $ vi fluentd.yml
197行目
value: us-east-1 <- ap-northeast-1 に変更
199行目
value: eksworkshop-eksctl <- eksctl-handson に変更
# デプロイ
$ kubectl apply -f fluentd.yml
```
