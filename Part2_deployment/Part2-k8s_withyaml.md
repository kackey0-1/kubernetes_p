
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
kubectl create deployment helloworld --image busybox --replicas 5 --dry-run=client -o yaml > deployment_multi_containers.yaml

# delete created pods/deployments by yaml
kubectl delete -f pod_multi_containers.yaml
kubectl delete -f deployment_multi_containers.yaml
```

### Pod/Deploymentマニフェストの比較
Podの上に、Deploymentの定義(replica, rolling update strategy)が存在していることが大きな違い
deploymentの配下にpodのspecsを定義
Deployment: ReplicaSetの世代管理
Replicaset: Podのレプリカを管理
Pod: コンテナの集合体
の順にオブジェクトが存在している

## KubernetesのStorage
### 環境変数をConfigMapで定義
ConfigMapは環境変数などをKey-Valueとして保存するリソース
マニフェストに直接環境変数を定義してもいいが、変数のreuseができないという問題が発生するためConfigMapを用意する

```
# create configmap
kubectl create configmap my-config --from-literal=TEST_ENV=Hello_World --dry-run -o yaml > configmap.yaml
```


