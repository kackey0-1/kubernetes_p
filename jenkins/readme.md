# Jenkins
### create namespace
```shell
kubectl create ns jenkins
```

### install helm
```shell
brew install helm
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
helm search repo jenkinsci
```

### create jenkins volume
```shell
kubectl create -f jenkins-volume.yaml
```

### install jenkins by helm
```shell
chart=jenkinsci/jenkins
helm install jenkins -n jenkins -f resources/jenkins-values.yaml $chart

```

after execution
```log
NAME: jenkins
LAST DEPLOYED: Thu Apr 22 17:17:37 2021
NAMESPACE: jenkins
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:
  kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  echo http://127.0.0.1:8080
  kubectl --namespace jenkins port-forward svc/jenkins 8080:8080

3. Login with the password from step 1 and the username: admin
4. Configure security realm and authorization strategy
5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http:///configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine

For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/


NOTE: Consider using a custom image with pre-installed plugins
```

### uninstall jenkins
```shell
helm uninstall jenkins -n jenkins
```
