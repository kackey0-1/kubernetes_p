# Exercises

## Create a namespace called 'mynamespace' and a pod with image nginx called nginx on this namespace [O]
```bash
kubectl create namespace mynamespace
kubectl run nginx --image=nginx --restart=Never -n mynamespace
```

## Create the pod that was just described using YAML [O]
```bash
kubectl run nginx --image=nginx --restart=Never -n mynamespace --dry-run=client -o yaml > nginx_pod.yaml
kubectl apply -f nginx_pod.yaml -n mynamespace
```

## Create a busybox pod (using kubectl command) that runs the command "env". Run it and see the output [O]
```bash
kubectl run busybox --image=busybox --restart=Never -n mynamespace --command -- env
kubectl run busybox --image=busybox --restart=Never -n mynamespace --it env
kubectl logs busybox -n mynamespace
```

## Create a busybox pod (using YAML) that runs the command "env". Run it and see the output [X]
```bash
kubectl run busybox --image=busybox --restart=Never -n mynamespace --dry-run=client -o yaml --command -- env > busybox_pod.yaml
kubectl apply -f busybox_pod.yaml
kubectl logs busybox -n mynamespace
```

## Get the YAML for a new namespace called 'myns' without creating it [O]
```bash
kubectl create namespace myns --dry-run=client -o yaml > myns_namespace.yaml
```

## Get the YAML for a new ResourceQuota called 'myrq' with hard limits of 1 CPU, 1G memory and 2 pods without creating it [O]
```bash
kubectl create quota myrq --hard=cpu=1,memory=1G,pods=2 --dry-run=client -o yaml > myrq_quota.yaml
```

## Get pods on all namespaces [X]
```bash
kubectl get po -A
```

## Create a pod with image nginx called nginx and expose traffic on port 80
```bash
kubectl run nginx --image=nginx --port 80 --restart=Never
# Not Necessary | kubectl expose pod/nginx --port 80 --target-port 80 --type NodePort --name nginx-nodeport 
```

## Change pod's image to nginx:1.7.1. Observe that the container will be restarted as soon as the image gets pulled
```bash
kubectl set image pod/nginx nginx=nginx:1.7.1
kubectl describe pod/nginx
kubectl get po nginx -w # watch it
```

## Get nginx pod's ip created in previous step, use a temp busybox image to wget its '/'
```bash
# Check IP Address for
kubectl get pod -o wide 
kubectl run busybox --image busybox --restart=Never -it wget http://172.17.0.4/
```

## Get pod's YAML
```bash
kubectl get pods -o yaml
kubectl get pod/nginx -o yaml
```

## If pod crashed and restarted, get logs about the previous instance [X]
```bash
# kubectl logs pod/nginx WRONG
kubectl describe pod/nginx
```

## Execute a simple shell on the nginx pod [X]
```bash
# kubectl run nginx --image nginx --restart=Never -it sh WRONG
# kubectl run busybox --image busybox --restart=Never -it /bin/sh WRONG
kubectl exec -it nginx -- sh
```

## Create a busybox pod that echoes 'hello world' and then exits [X]
```bash
kubectl run busybox --image busybox --restart=Never -it echo "hello world"
exit
```

## Do the same, but have the pod deleted automatically when it's completed [X]
```bash
kubectl run busybox --image=busybox --restart=Never --rm=true -it sh # WRONG
```

## Create an nginx pod and set an env value as 'var1=val1'. Check the env value existence within the pod
```bash
kubectl run nginx --image=nginx --restart=Never --env="var1=val1"
kubectl exec nginx -it -- env
```


