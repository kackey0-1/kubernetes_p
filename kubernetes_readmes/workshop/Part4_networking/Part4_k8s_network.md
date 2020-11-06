# Kubernetes Networking

## Namespaceの管理
1つのクラスター内で、仮想のクラスターに分けられる開発、運用、テスト環境をNamespaceで分ける

```bash
# create namespace <staging>
kubectl create namespace staging
# create pod in staging namespace
kubectl run --image gcr.io/google-samples/hello-app:1.0 --namespace staging helloworld
# get pods in staging
kubectl get pod --namespace staging
# delete pod in staging
kubectl delete pod helloworld --namespace staging
```

## Docker Network Mode
### Bridge Mode
ホストの中のDockerBridgeネットワークからIPが振り分けられるためIPレンジがホストと異なる
### Host Mode
ホストのIPレンジからIPが振り分けられホストポートを使うため`-p 8080:80`のようなMappingができない
### Null Mode
コンテナはBridgeにもHostネットワークにもリンクされずIPもないため接続不可の状態となる
### Overlay Mode(Kubernetes/Docker Swarm)
複数ホストがある場合に使う

```bash
# show network driver(bridge, host, null)
docker network ls
# create network driver
docker network create --driver bridge custom_bridge
# delete network
docker network rm custom_bridge
```

## Overlay Networkとは？
異なるホスト上のPodにアクセスするためには、各ホストでRoutingをする必要があるが、
Overlay Networkを利用する事によりCluster側でRoute Tableを提供しよし何やってくれる。
それを実現するために`CNI(Container Network Interface) Plugin`が提供されている。
Example: Calico, Flan


