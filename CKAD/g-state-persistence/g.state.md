![](https://gaforgithub.azurewebsites.net/api?repo=CKAD-exercises/state&empty)
# State Persistence (8%)

## Define volumes 
### Create busybox pod with two containers, each one will have the image busybox and will run the 'sleep 3600' command. Make both containers mount an emptyDir at '/etc/foo'. Connect to the second busybox, write the first column of '/etc/passwd' file to '/etc/foo/passwd'. Connect to the first busybox and write '/etc/foo/passwd' file to standard output. Delete pod.
```shell
kubectl run busybox --image=busybox --dry-run=client -o yaml -- /bin/sh -c 'sleep 3600' > two-busybox.yaml
# vim two-busybox.yaml
kubectl exec busybox -c busybox1 -it -- /bin/sh
cat /etc/passwd > /etc/foo/passwd
kubectl exec busybox -c busybox2 -it -- /bin/sh
cat /etc/foo/passwd
```
### Create a PersistentVolume of 10Gi, called 'myvolume'. Make it have accessMode of 'ReadWriteOnce' and 'ReadWriteMany', storageClassName 'normal', mounted on hostPath '/etc/foo'. Save it on pv.yaml, add it to the cluster. Show the PersistentVolumes that exist on the cluster
```shell
kubectl create -f pv.yaml
kubectl get pv myvolume
```
### Create a PersistentVolumeClaim for this storage class, called mypvc, a request of 4Gi and an accessMode of ReadWriteOnce, with the storageClassName of normal, and save it on pvc.yaml. Create it on the cluster. Show the PersistentVolumeClaims of the cluster. Show the PersistentVolumes of the cluster
```shell
touch pvc.yaml
kubectl create -f pvc.yaml
kubectl get pv,pvc
```
### Create a busybox pod with command 'sleep 3600', save it on pod.yaml. Mount the PersistentVolumeClaim to '/etc/foo'. Connect to the 'busybox' pod, and copy the '/etc/passwd' file to '/etc/foo/passwd'
```shell
kubectl run busybox --image=busybox --dry-run=client -o yaml -- /bin/sh -c 'sleep 3600' > pod.yaml
# vim pod.yaml
kubectl create -f pod.yaml
kubectl exec busybox -c busybox -it -- sh
cat /etc/passwd > /etc/foo/passwd
```
### Create a second pod which is identical with the one you just created (you can easily do it by changing the 'name' property on pod.yaml). Connect to it and verify that '/etc/foo' contains the 'passwd' file. Delete pods to cleanup. Note: If you can't see the file from the second pod, can you figure out why? What would you do to fix that?
```shell
cat pod.yaml > pod-2.yaml
kubectl create -f pod-2.yaml
kubectl exec busybox2 -it -- sh
```
### Create a busybox pod with 'sleep 3600' as arguments. Copy '/etc/passwd' from the pod to your local folder
```shell
kubectl run pod --image=busybox -- 'sleep 3600'
kubectl cp -c busybox /etc/passwd busybox:/etc/passwd
kubectl delete pod busybox
```