# Create a Pod with two containers, both with image busybox and command "echo hello; sleep 3600". Connect to the second container and run 'ls' [X]
```bash
kubectl run busybox --image=busybox --restart=Never --dry-run=client -o yaml --command -- /bin/sh "echo hello; sleep 3600" > multi-container_pod.yaml
kubectl exec pod/busybox -c busybox2 -it /bin/sh
ls
exit
kubectl delete pod/busybox
```

# Create pod with nginx container exposed at port 80. Add a busybox init container which downloads a page using "wget -O /work-dir/index.html http://neverssl.com/online". Make a volume of type emptyDir and mount it in both containers. For the nginx container, mount it on "/usr/share/nginx/html" and for the initcontainer, mount it on "/work-dir". When done, get the IP of the created pod and create a busybox pod and run "wget -O- IP" [X]
```bash
# kubectl run nginx --image=nginx --port 80 --restart=Never --dry-run=client -o yaml > multi-nginx_pod.yaml
# kubectl run busybox --image=busybox --restart=Never --dry-run=client -o yaml --command -- wget -O /work-dir/index.html http://neverssl.com/online > busybox-temp.yaml
### WRONG

kubectl run nginx --image=nginx --port 80 --restart=Never --dry-run=client -o yaml > nginx-init.yaml
cat nginx-init.yaml
kubectl apply -f nginx-init.yaml
kubectl apply -f not-wrong-nginx-init.yaml # Also OK
kubectl get pod/nginx -o wide
kubectl run busybox --image=busybox --restart=Never --rm -it wget -O- 172.17.0.4
kubectl run box --image=busybox --restart=Never --rm -it -- /bin/sh -c "wget -O- IP"
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  initContainers:
  - args: #
    - /bin/sh #
    - -c #
    - wget -O /work-dir/index.html http://neverssl.com/online #
    image: busybox
    name: busybox
    volumeMounts:
    - name: vol
      mountPath: /work-dir

  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    resources: {}
    volumeMounts:
    - name: vol
      mountPath: /usr/share/nginx/html
  dnsPolicy: ClusterFirst
  restartPolicy: Never

  volumes:
  - name: vol
    emptyDir: {}
status: {}

```
