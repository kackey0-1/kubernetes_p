![](https://gaforgithub.azurewebsites.net/api?repo=CKAD-exercises/services&empty)
# Services and Networking (13%)

### Create a pod with image nginx called nginx and expose its port 80
```shell
kubectl run nginx --image=nginx --port=80 --expose
```
### Confirm that ClusterIP has been created. Also check endpoints
```shell
kubectl get po,svc
kubectl get endpoints
```
### Get service's ClusterIP, create a temp busybox pod and 'hit' that IP with wget
```shell
kubectl get endpoints  # | grep nginx | aw '{print $2}'
kubectl run busybox --image=busybox -it -- sh
wget ip:port
```
### Convert the ClusterIP to NodePort for the same service and find the NodePort port. Hit service using Node's IP. Delete the service and the pod at the end.
```shell
#kubectl run nginx --image=nginx --dry-run=client --port=80 --expose -o yaml > nginx-nodeport.yaml
# vi nginx-nodeport.yaml
kubectl edit svc nginx
# add spec.type: NodePort
kubectl get po,svc
wget NODEPORT_IP:PORT
```
### Create a deployment called foo using image 'dgkanatsios/simpleapp' (a simple server that returns hostname) and 3 replicas. Label it as 'app=foo'. Declare that containers in this pod will accept traffic on port 8080 (do NOT create a service yet)
```shell
kubectl create deploy foo --image=dgkanatsios/simpleapp --replicas=3 -l app=foo --port=8080
```
### Get the pod IPs. Create a temp busybox pod and try hitting them on port 8080
```shell
kubectl get pod -o wide
kubectl run temp --image=busybox -it -- sh
wget 172.17.0.4:8080 
```
### Create a service that exposes the deployment on port 6262. Verify its existence, check the endpoints
```shell
kubectl create svc clusterip foo --tcp=6262:8080
kubectl get svc -o wide
#minikube service foo
kubectl get po,svc
```
### Create a temp busybox pod and connect via wget to foo service. Verify that each time there's a different hostname returned. Delete deployment and services to cleanup the cluster
```shell
kubectl get svc -o wide
kubectl run temp --image=busybox -it -- sh
wget FOOS_IP:6262
kubectl delete deploy,svc foo
```
### Create an nginx deployment of 2 replicas, expose it via a ClusterIP service on port 80. Create a NetworkPolicy so that only pods with labels 'access: granted' can access the deployment and apply it
```shell
kubectl create deploy nginx --image=nginx --replicas=2
kubectl expose deploy nginx --port=80 --target-port=80
#kubectl create svc clusterip nginx --tcp=80:80 --dry-run=client -o yaml >> deploy.yaml
# add metadata.labels.access: granted
# add spec.selector.access: granted
#kubectl create -f deploy.yaml
#kubectl get pod,svc,rs,deploy

# wget by busybox
kubectl get svc -o wide
kubectl run busybox --image=busybox --restart=Never --rm -it -- wget -O- http://nginx:80 --timeout 2
kubectl run busybox --image=busybox --restart=Never --labels=access=granted --rm -it -- wget -O- http://nginx:80 --timeout 2
```