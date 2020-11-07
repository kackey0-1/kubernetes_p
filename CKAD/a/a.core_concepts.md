# Exercises
## Create a namespace called 'mynamespace' and a pod with image nginx called nginx on this namespace
```bash
kubectl create namespace mynamespace
kubectl run nginx --image=nginx --restart=Never -n mynamespace
```

## Create the pod that was just described using YAML
```bash
kubectl run nginx --image=nginx --restart=Never -n mynamespace --dry-run=client -o yaml > nginx_pod.yaml
kubectl apply -f nginx_pod.yaml -n mynamespace
```

## Create a busybox pod (using kubectl command) that runs the command "env". Run it and see the output
```bash
kubectl run busybox --image=busybox --restart=Never -n mynamespace --command -- env
kubectl run busybox --image=busybox --restart=Never -n mynamespace --it env
kubectl logs busybox -n mynamespace
```

## Create a busybox pod (using YAML) that runs the command "env". Run it and see the output
```bash
```

## Get the YAML for a new namespace called 'myns' without creating it

## Get the YAML for a new ResourceQuota called 'myrq' with hard limits of 1 CPU, 1G memory and 2 pods without creating it

## Get pods on all namespaces

## Create a pod with image nginx called nginx and expose traffic on port 80

## Change pod's image to nginx:1.7.1. Observe that the container will be restarted as soon as the image gets pulled

## Get nginx pod's ip created in previous step, use a temp busybox image to wget its '/'

## Get pod's YAML

## If pod crashed and restarted, get logs about the previous instance

## Execute a simple shell on the nginx pod

## Create a busybox pod that echoes 'hello world' and then exits

## Do the same, but have the pod deleted automatically when it's completed

## Create an nginx pod and set an env value as 'var1=val1'. Check the env value existence within the pod


