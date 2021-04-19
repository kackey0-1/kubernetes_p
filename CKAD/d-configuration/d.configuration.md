# Configuration (18%)

## ConfigMaps
### Create a configmap named config with values foo=lala,foo2=lolo
```shell
kubectl create configmap config --from-literal=foo=lala --from-literal=foo2=lolo
kubectl describe configmap config 
kubectl get configmap config -o yaml
```
### Display its values
```shell
kubectl describe cm config
```
### Create and display a configmap from a file
```shell
echo -e "foo3=lili\nfoo4=lele" > config.txt
kubectl create configmap fromfile --from-file=config.txt
kubectl describe cm fromfile
kubectl get cm fromfile -o yaml
```
### Create and display a configmap from a .env file
```shell
echo -e "var1=val1\n# this is a comment\n\nvar2=val2\n#anothercomment" > config.env
kubectl create cm fromenv --from-file=config.env
kubectl describe cm fromenv
kubectl get cm fromenv -o yaml
```
### Create and display a configmap from a file, giving the key 'special'
```shell
echo -e "var3=val3\nvar4=val4" > config4.txt
kubectl create cm config4 --from-file=special=config4.txt
kubectl describe cm config4
kubectl get cm config4 -o yaml
```
### Create a configMap called 'options' with the value var5=val5. Create a new nginx pod that loads the value from variable 'var5' in an env variable called 'option'
```shell
kubectl create cm options --from-literal=var5=val5
kubectl run nginx --image=nginx --dry-run=client -o yaml > nginx-configmap.yaml
kubectl create -f nginx-configmap.yaml
kubectl exec -it pod/nginx -- /bin/bash
```
### Create a configMap 'anotherone' with values 'var6=val6', 'var7=val7'. Load this configMap as env variables into a new nginx pod
```shell
kubectl create configmap anothoerone --from-literal=var6=val6 --from-literal=var7=val7
kubectl run nginx2 --image=nginx --dry-run=client -o yaml > nginx-envvariables.yaml
kubectl create -f nginx-envvariables.yaml
kubectl exec -it pod/nginx2 -- /bin/bash
echo $var6
echo $var7
```
### Create a configMap 'cmvolume' with values 'var8=val8', 'var9=val9'. Load this as a volume inside an nginx pod on path '/etc/lala'. Create the pod and 'ls' into the '/etc/lala' directory.
```shell
kubectl create configmap cmvolume --from-literal=var8=val8 --from-literal=var9=val9
kubectl run nginx3 --image=nginx --dry-run=client -o yaml > nginx-cmvolume.yaml
kubectl create -f nginx-cmvolume.yaml

kubectl exec -it pod/nginx3 -- /bin/bash
echo $var8
echo $var9
```
## SecurityContext
### Create the YAML for an nginx pod that runs with the user ID 101. No need to create the pod
```shell
kubectl run nginx --image=nginx --dry-run=client -o yaml > nginx-userid.yaml
# vim nginx-userid.yaml and add spec.securityContext.runAsUser: 101
# kubectl create -f nginx-userid.yaml
```
### Create the YAML for an nginx pod that has the capabilities "NET_ADMIN", "SYS_TIME" added on its single container
```shell
kubectl run nginx --image=nginx --dry-run=client -o yaml > nginx-capabilities.yaml
# vim nginx-capabilities.yaml and add capabilities properties
# or
```
## Requests and limits
### Create an nginx pod with requests cpu=100m,memory=256Mi and limits cpu=200m,memory=512Mi
```shell
kubectl run nginx --image=nginx --requests='cpu=100m,memory=256Mi' --limits='cpu=200m,memory=512Mi'
kubectl run nginx --image=nginx --requests='100m,memory=256Mi' --limits='200m,memory=512Mi'
```

## Secrets
### Create a secret called mysecret with the values password=mypass
### Create a secret called mysecret2 that gets key/value from a file
### Get the value of mysecret2
### Create an nginx pod that mounts the secret mysecret2 in a volume on path /etc/foo
### Delete the pod you just created and mount the variable 'username' from secret mysecret2 onto a new nginx pod in env variable called 'USERNAME'

## ServiceAccounts
### See all the service accounts of the cluster in all namespaces
### Create a new serviceaccount called 'myuser'
### Create an nginx pod that uses 'myuser' as a service account
