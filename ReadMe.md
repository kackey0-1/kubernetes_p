# Kubernetes
- Dockerなどのコンテナをうまく管理するツール

### なぜk8sが必要か
docker run vs docker-composeの違いは同一ホスト上での複数コンテナかどうか
->コンテナが故障した場合、正常にサービスを提供できなくなるというリスクが発生してしまう
その事態を避けるためにホストを大量生産して複数コンテナを複数ホストに振り分けようというのがContainer Orchestration(SPFを防ぐ意図)

|Docker|k8s|
|---|---|
|Dockerは単一ホスト内の複数コンテナ同士はやりとりできるが、複数マシン上で外側とのやりとりにNATが必要|k8sはDockerコンテナをクラスタ化した際の運用ツールの1つ|
|Dockerは、ホスト間の連携が煩雑になるため容易にスケールアウトできない|k8sは複数台ホストの管理・統合させるためのシステムで構成される実行環境をあたかも一台の実行環境のように扱う|

### k8sのメリット
- 稼働中にアプリをスケールする(水平の自動スケーリング/CPU稼働率の閾値でコンテナを増減)
- 複数ホスト上の複数コンテナへのロードバランシング(service, L4LB)
- 認証と認可の提供、資源の監視、ログ一括管理

## Kubernetes Master&Worker Architecture
kubernetest client -> Server(Master) -> Node(Worker)
Master: サーバー(自動配置、負荷分散、死活監視、自動修復)
Node: Worker(Masterからの命令を実行)

### kubectlとは
1. マニフェストに基づきマスターに操作をさせる
2. Cluster Endpointとユーザー認証のCertを~/.kube/configに保存

### Podとは
- Podはコンテナをグループ化する
- Podは管理上の基本単位で仮想NICを共有し(同じIP、同じVolumeファイルシステム)、仮想ホストのような動きをする

### Deploy 'Hello World' on k8s
```
# Hello WorldのPodを起動
kubectl run --image gcr.io/google-samples/hello-app:2.0 --restart Never helloworld
# Podを表示(List)
kubectl get pods
# Pod内のコンテナのログを表示
kubectl logs helloworld
# Podのメタデータを表示
kubectl describe pod helloworld
# Pod内のコンテナにShell接続
kube exec -it helloworld sh
# Pod内のコンテナの環境変数を定義
kubectl run --env TEST_ENV=hello_world --image gcr.io/google-samples/hello-app:2.0 --restart Never helloworld
# クラスター内にcurlコンテナを作成し、Shell接続 (--rm=)
kubectl run --restart Never --image curlimages/curl:7.68.0 -it --rm curl sh
# HelloWorld PodへのCurlアクセステスト(クラスター外からPodへ接続は不可: Networkが異なるため) 
curl 172.17.0.3:8080
# HelloWorld Podから返事
```

### Serviceとは
- Podをクラスター内外に公開する静的IPを持ったL4LB(LoadBalancer)
- クラスター内外からPodへの安定的なアクセスを提供できる仮想のIPアドレスをServiceに割り当てる
- Podはいつ消えるかわからないため、Static IPを持つことでPodのIPを管理しなくて良くなる

#### 3つのServiceタイプ
- Cluster IP
- NodePort
- LoadBalancer

##### Cluster IP Service 
Cluster IPのServiceを使う利点は、いつ消えるかわからないPod IPを抽象化し、StaticIPを持ったProxyを置くことで
1. Podにアクセスする際に、Pod IPを知る必要がなくなる
2. Podにアクセスする際に、ロードバランスしてくれる

restart=Never にするのはDeploymentリソース作成を避けるため

```
#  Helloworld PodをClusterIPのサービスとしてクラスタ内部で公開
kubectl expose pod helloworld --type ClusterIP --port 8080 --name helloworld-clusterip
# Serviceをリストアップ
kubectl get service
# クラスター内にCurlコンテナのPodを作成しShell接続
kubectl run --restart Never --image curlimages/curl:7.68.0 -it --rm curl sh
# 'helloworld' ClusterIP Serviceへcurlでアクセステスト
curl helloworld-clusterip:8080
# 'helloworld' ClusterIP Service経由でPodから返事が返ってくること
# clusterip serviceは内部に公開しているだけのため、Cluster外部からアクセスはできない
```

##### NodePort
NodePortのServiceを使う利点は、ClusterIPでは不可能だった、クラスター外へのPodの公開をNodeIPとNodePort経由で可能
問題点としては、NodeIP、NodePortを知る必要があるということ。Nodeも起動・停止によりIP/Portが入れ替わる必要がある。
そのため、ロードバランサーをNodesの前に置きStatic IPとDNSを与えることでNodeIPを知る必要がなくなる。
その機能を兼ね備えているのがServiceのLoadBalancerタイプ
```
# helloworld PodをNodePortのServiceとしてクラスタ内部で公開
kubectl expose pod helloworld --type NodePort --port 8080 --name helloworld-nodeport
# Serviceをリストアップ
kubectl get service
# クラスター内にCurlコンテナのPodを作成しShell接続
kubectl run --restart Never --image curlimages/curl:7.68.0 -it --rm curl sh
# 'helloworld' NodePort ServiceへCurlでアクセステスト
curl helloworld-nodeport:8080
# Node IPとNodePortを取得する
minicube service helloworld-nodeport --url
```

##### LoadBalancer
クラウドプロバイダーのL4LBのDNSから、各ノードの特定ポートにRoutingしてPodにアクセスする。
問題点として、
1. 1つのServiceごとに1つのLBが作られてします(高コスト)
2. L4のLBなのでTCI/IPまでしかわからず、L7のHTTPのホスト・パスでLB振り分けができない
そのため、L7レベル(URLごとなど)のHTTPホスト・パスでLBの振り分けをするにはIngressを使う

```
# helloworld PodをLoadBalancerのServiceとしてクラスタ内部で公開
kubectl expose pod helloworld --type LoadBalancer --port 8080 --name helloworld-lb
# Serviceをリストアップ
kubectl get service -o wide
# Cluster内にcurlコンテナのPodを作成しshell接続
kubectl run --restart Never --image curlimages/curl:7.68.0 -it --rm curl
# helloworld LoadBalancer serviceへcurlでアクセステスト
curl helloworld-lb:8080
# Cluster外のMacからNodeIPとNodePortを指定してCurlすると接続可能
# -> k8sクラスターをクラウドで運用する場合は、このLoadBalancerのServiceにLBのPublicIPとDNSが与えられる。
curl $(minikube service helloworld-lb --url)
```

### Ingressとは
1. Podをクラスター内外に公開するL7LB
2. クラスター外部からURLのホスト・パスによるServiceへの振り分けができる
```
# Minikube Addonsをリストアップ
minikube addons list
# Ingress addonを追加
minikube addons enable ingress
# Ingress Controller Podをチェック
kubectl get pods -n kube-system
```

ingressを作り、helloworld Podをすべてのパス`/`で公開
```
# Ingressをマニフェストから作成
kubectl apply -f ingress.yaml
# ingressリストアップ
kubectl get ingress
# ingress resourceの詳細表示
kubectl describe ingress helloworld
# ingress controller(ALB)のIPを取得
kubectl get ingress | aws '{ print $4 }' | tail -1
# Ingress経由で、helloworld-nodeport Serviceにアクセス
curl $(kubectl get ingress | aws '{ print $4 }' | tail -1)
```

ingress resourceに新しいパスを定義
```
# hello-app:2.0のPodを生成
kubectl run --image gcr.io/google-samples/hello-app:2.0 --port 8080 --restart Never helloworld-v2
# NodePort Service生成
kubectl expose pod helloworld-v2 --type NodePort --port 8080 --name helloworld-v2-nodeport
# new ingress 生成
kubectl apply -f ingress_path.yaml

```

### ReplicaでPodをスケールアップ(冗長化)
- ReplicaはPodを複製する
- Specで定義されたReplica数を自動配置・維持(配備と冗長化)する

```
# PodをReplicaSetとして1つ起動
kubectl apply -f replicaset.yaml
# Replicasetをリストアップ
kubectl get replicaset
# 3つにスケールアップ
kubectl scale --replicas=5 replicaset/helloworld
# 1つPodを停止
kubectl delete pod POD_ID
```

## Kubernetes Storage
- PVC(永続ボリューム)
- 