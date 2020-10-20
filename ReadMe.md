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

```
```

##### LoadBalancer

```
```

## Kubernetes Storage
- PVC(永続ボリューム)
- 