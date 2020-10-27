
## Imperative vs Declarativeの違いは?
|Imperative(命令的)|Declarative(宣言的)|
|---|---|
|HOW(how-to)を指定して結果をコントロール|What(最終的なdesired state)を指定することで結果をコントロール|
||YAMLに定義することによりインフラの状態を定義可能|
||YAMLに定義することによりインフラの状態を定義可能|
|命令的(kubectl run)|宣言的(kubernetes yaml)|

```
# k8sコマンドからyamlを自動生成
## pod
kubectl run --image gcr.io/google-samples/hello-app:1.0 --restart Never Helloworld --dry-run -o yaml helloworld > pod.yaml
## service
kubectl expose pod helloworld --type ClusterIP --name helloworld-clusterip --port 8080 --dry-run -o yaml > service.yaml
## deployment
kubectl create deployment helloworld --image gcr.io/google-samples/hello-app:1.0 --dry-run=client -o yaml > deployment.yaml
```

## Pod Yamlで複数コンテナを起動

```
kubectl run --port 8080 --image busybox --restart Never --dry-run -o yaml --command helloworld -- /ben/sh -c sleep 500 > pod_multi_containers.yaml
```