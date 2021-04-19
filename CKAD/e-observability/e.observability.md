![](https://gaforgithub.azurewebsites.net/api?repo=CKAD-exercises/observability&empty)
# Observability (18%)

## Liveness and readiness probes
### Create an nginx pod with a liveness probe that just runs the command 'ls'. Save its YAML in pod.yaml. Run it, check its probe status, delete it.
```shell
kubectl run nginx --image=nginx --dry-run=client -o yaml > nginx-liveness.yaml
kubectl create -f nginx-liveness.yaml
```
### Modify the pod.yaml file so that liveness probe starts kicking in after 5 seconds whereas the interval between probes would be 5 seconds. Run it, check the probe, delete it.
```shell
kubectl run nginx --image --dry-run=client -o yaml > pod.yaml
kubectl create -f pod.yaml
kubectl describe pod/nginx | grep -i liveness
kubectl delete -f pod.yaml
```
### Create an nginx pod (that includes port 80) with an HTTP readinessProbe on path '/' on port 80. Again, run it, check the readinessProbe, delete it.
```shell
kubectl run nginx --image=nginx --dry-run=client --port=80 -o yaml > nginx-readinessprobe.yaml
kubectl create -f nginx-readinessprobe.yaml
kubectl delete -f nginx-readinessprobe.yaml
```
### Lots of pods are running in `qa`,`alan`,`test`,`production` namespaces.  All of these pods are configured with liveness probe.  Please list all pods whose liveness probe are failed in the format of `<namespace>/<pod name>` per line.
```shell
kubectl get events -n qa | grep -i failed
kubectl get events -n alan | grep -i failed
kubectl get events -n test | grep -i failed
kubectl get events -n production | grep -i failed
```
## Logging
### Create a busybox pod that runs 'i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 1; done'. Check its logs
```shell
kubectl run busybox --image=busybox -- /bin/sh -c 'i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 1; done'
kubectl logs pod busybox
# or
kubectl logs pod/busybox -f
kubectl delete pod/busybox
```

## Debugging
### Create a busybox pod that runs 'ls /notexist'. Determine if there's an error (of course there is), see it. In the end, delete the pod
```shell
kubectl run busybox --image=busybox -- 'ls /notexist'
kubectl logs pod busybox
kubectl describe pod busybox
kubectl delete pod/busybox
```
### Create a busybox pod that runs 'notexist'. Determine if there's an error (of course there is), see it. In the end, delete the pod forcefully with a 0 grace period
```shell
kubectl run busybox --image=busybox -- 'notexist'
kubectl describe pod busybox
kubectl logs pod busybox
kubectl get events | grep -i error
kubectl delete pod/busybox
```
### Get CPU/memory utilization for nodes ([metrics-server](https://github.com/kubernetes-incubator/metrics-server) must be running)
```shell
kubectl top nodes
```