# Kubernetes
## Podとは
- Kubernetesの最小デプロイ単位
- 1つ以上のコンテナとストレージボリュームの集まり
- 同一Pod内のコンテナは同一Nodeに配置される
  - 「同一Node動作する必要があるか？」がPod構成の基準
- 1つのPodないのコンテナは同じIPアドレスとPortを使用する
  - Pod内のコンテナ間の通信はプロセス間通信として行う
## ReplicaSet
- 同じ仕様のPodが指定した数だけ存在するよう生成・管理する
  - Podが死んだ時も指定した数になるように自動回復してくれる
- PodとReplicaSetは疎結合
  - Labelというメタデータを使って都度検索する
  - 手動でPodのLabelを書き換えれば、ReplicaSetから切り離してデバッグするといったことも可能
## Deployment
- 新しいバージョンのリリースを管理するための仕組み
  - ReplicaSetの変更を安全に反映させる/世代管理する
  - Podのスケール、コンテナの更新、ロールバックetc...
- 2つのDeployment戦略
  - Recreate
  - RollingUpdate
- ReplicaSetとDeploymentも疎結合
## Service
- Podの集合(主にReplicaSet)に対する経路やサービスディスカバリを提供
  - クラスタ内DNSで、"<Service名>.<Namespace名>"で名前解決可能
  - 同じNamespace内なら"<Service名>"だけでOK
- Labelによって対象のPodが検索される
  - 対象のPodが動的に入れ替わったりしても、Labelがあれば一貫した名前でアクセス可能
## Ingress
- Serviceをクラスタ外に公開
- NodePortタイプのServiceと違い、パスベースで転送先のServiceを切り替えることも可能
  - Service(NonePort): L4レベルでの制御
  - Ingress: L7レベルでの制御
## Masterについて
MasterもPodの集まり
- etcd
  - クラスタないの様々なデータを保存している一貫性のある高可用性のKVS
- kube-apiserver
  - クラスタに対する全ての操作を司るAPIサーバー
  - 認証や認可の処理なども行う
- kube-scheduler
  - PodのNodeへの割り当てを行うスケジューラー
  - Podを配置するNodeの選択も行う
- kube-controller-manager
  - 各種Kubernetesオブジェクトのコントローラーを起動し管理するマネージャー
- kubelet
  - Nodeのメイン処理であるPodの起動・管理を行うエージェント
- kube-proxy
  - serviceが持つ仮想的なIPアドレス(ClusterIP)へのアクセスをルーティングする
# Kubenetes HandsOn
## とりあえず触ってみる
### kubectlで操作するKubernetes Clusterをdocker-for-desktopに設定　
$ kubectl config use-context docker-for-desktop
### 設定されているかの確認
$ kubectl config current-context
### 動作確認
$ kubectl get pods --namespace=kube-system
### docker-for-desktopでingressが使えるように下準備
Ingressとは、Serviceの一つ上にロードバランサとして設置()
[reference](https://kubernetes.github.io/ingress-nginx/deploy/)
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/cloud/deploy.yaml
### デプロイ
$ kubectl apply -f examples/guestbook/
### ingressの有効化
$ cat << 'EOT' >./guestbook-ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: guestbook-ingress
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          serviceName: frontend
          servicePort: 80
EOT
### ingressのデプロイ
$ kubectl apply -f guestbook-ingress.yaml
### ADDRESSがlocalhostになるまで待機
$ kubectl get ingress
### deployment一覧
$ kubectl get deploy -o wide
### Deployment詳細
$ kubectl describe deploy frontend
### ReplicaSet一覧
$ kubectl get rs -o wide
### ReplicaSet詳細
$ kubectl describe rs frontend-6cb7f8bd65
### Pod一覧
$ kubectl get pod -o wide
### Pod詳細
$ kubectl describe pod frontend-6cb7f8bd65-gjd29
### Podのログ
$ kubectl logs frontend-6cb7f8bd65-gjd29
### Service一覧
$ kubectl get svc -o wide
### Service詳細
$ kubectl describe svc frontend
### Ingress一覧
$ kubectl get ing
### Ingress詳細
$ kubectl describe ing guestbook-ingress
## スケールさせてみる
###  frontendのPodを2つに増やす
$ vi examples/guestbook/frontend-deployment.yaml
line 10: replicas: 1 <- 2に変更
$ kubectl apply -f examples/guestbook/frontend-deployment.yaml
###  pod数の確認
$ kubectl get pod -o wide
## 意図的にPodを削除
### 先ほど増えた2つ目のPodを削除
$ kubectl delete pod frontend-6cb7f8bd65-jsh8h
### 新しいPodが生成されることを確認
$ kubectl get pod -o wide
## Podの設定を変えてみる
### Podの変更が起こらないと履歴が記録されないため、試しにしようメモリを変更
$ vi examples/guestbook/frontend-deployment.yaml
line23: memory: 100Mi <- 120Miに変更
$ kubectl apply -f examples/guestbook/frontend-deployment.yaml
$ kubectl get pod
### 履歴をみる()
$ kubectl rollout history deployments frontend
### Revision=2の詳細をみる
$ kubectl rollout history deployments frontend --revision=2
### Revision=1にロールバックしてみる
$ kubectl rollout undo deployments frontend --to-revision=1
$ kubectl rollout history deployments frontend
## Masterの動き
$ kubectl get pod --namespace=kube-system -o wide
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-5644d7b6d9-bnrhh                 1/1     Running   0          6h16m
coredns-5644d7b6d9-g98ft                 1/1     Running   0          6h16m
etcd-docker-desktop                      1/1     Running   0          6h15m
kube-apiserver-docker-desktop            1/1     Running   0          6h15m
kube-controller-manager-docker-desktop   1/1     Running   0          6h15m
kube-proxy-6shqr                         1/1     Running   0          6h16m
kube-scheduler-docker-desktop            1/1     Running   0          6h15m
storage-provisioner                      1/1     Running   0          6h15m
vpnkit-controller                        1/1     Running   0          6h15m
### guestbookアプリケーションを削除
$ kubectl delete -f examples/guestbook/
