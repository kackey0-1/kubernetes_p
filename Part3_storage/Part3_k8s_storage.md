# KubernetesのStorage

### 環境変数をConfigMapで定義
ConfigMapは環境変数などをKey-Valueとして保存するリソース
マニフェストに直接環境変数を定義してもいいが、変数のreuseができないという問題が発生するためConfigMapを用意する
```
# create configmap
kubectl create configmap my-config --from-literal=TEST_ENV=Hello_World --dry-run -o yaml > configmap.yaml
# apply configmap
kubectl apply -f configmap.yaml
# describe configmap my-config
kubectl describe configmap my-config
```

### ConfigMapで定義した環境変数をPodで引用
```
# create pod yaml
kubectl run --env TEST_ENV=Hello_World --port 8080 --image gcr.io/google-samples/hello-app:1.0 --dry-run=client -o yaml helloworld > pod_env.yaml 
# create pod by yaml
kubectl apply -f pod_env.yaml
# call env command in container
kubectl exec <pod_name> -contariner <container_name> -- env
```

### Docker Volumeマウントについて
コンテナ内のデータは起動、停止、再作成のライフサイクルの中で削除される
そのため、ホスト上のフォルダとコンテナ内のフォルダを指定してホストVolumeをマウントするのが一般的
Command Sample: `docker run --volumn /opt/datadir:/var/lib/mysql` 

