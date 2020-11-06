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
Docker Command Sample: `docker run --volumn /opt/datadir:/var/lib/mysql` 

```
docker run -d -v $(pwd):/home --name ubuntu -it ubuntu sleep 500
docker exec -it ubuntu bash
cd home && touch from_container.txt
exit
```

### ConfigMapで定義してPod内にVolumeをマウント
k8sの場合、Podが管理上の基本単位であり、仮想NICを共有(同じIP、同じVolumeファイルシステム)
つまり、PodはKubernetes上でホストに相当する単位
ConfigMapをPodにVolumeマウント

```
kubectl apply -f pod_volume.yaml
kubectl exec -it helloworld-configmap-volume sh
cat my-config/TEST_ENV/keys
```

### SSL CertやTokenをSecretとしてConfigMapで定義
- SecretはBase64でエンコードしてKey-Valueペアとして保存するリソース
- Base64なので、Encryptionとは異なり誰でもDecodeできるためDB PasswordなどはSecretに保存すべきでない

```
# create secret
kubectl create secret generic my-secret \
--from-literal=SECRET_KEY1=SECRET_VALUE1 \
--from-literal=SECRET_KEY2=SECRET_VALUE2 \
--dry-run -o yaml > secret.yaml

# apply secret
kubectl apply -f secret.yaml

# describe secret info
kubectl describe secret my-secret

# Secretをpodにvolumeマウント
kubectl apply -f pod_secret.yaml

# bash login
kubectl exec -it helloworld-secret-volume sh
```

### Persistent Volume(永続ボリューム要求)とは？
コンテナが書くデータをPod内のVolumeではなく、
クラスターワイドのNode上に存在するPersistent Volume(永続ボリューム)に
保存することでPodが消えてもデータはクラスター上に残る

```bash
# NodeにSSHしファイル作成
minikube ssh 
sudo mkdir mnt/pvc && echo "hello world" > mnt/pvc/hello_world.txt
exit

# Create Persistent Volume
kubectl apply -f persistent_volume.yaml

# Create Persistent Volume Claim
kubectl apply -f persistent_volume_claim.yaml

# PodでShellで入り、ファイルを作成
kubectl exec -it helloworld-pvc sh \ 
echo "from pod" > /mnt/pvc/from_pod.txt

# NodeにSSHし、ファイルコンテンツを表示
minikube ssh
cat /mnt/pvc/from_pod.txt
exit
```

#### pv.yaml(永続ボリューム)
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv
spec:
  storageClassName: manual
  capacity:
    storage: 100M # Volumeサイズを100MB指定
  accessModes: ReadWriteOnce
  hostPath: # Node上のパスを指定
    path: "/mnt/pvc"
```

#### pvc.yaml(永続ボリューム要求)
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests: # 10MBをPVから要求
      storage: 10M
```

