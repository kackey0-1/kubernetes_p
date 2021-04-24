# About Helm
The application manager like yum for CentOS or apt for Ubuntu,
which helps to manage Kubernetes applications.
Helm allows you to define, install, and upgrade even most complex Kubernetes applications.

## Why helm ?
- Deployment speed
- Prebuild application configurations
- Easy rollbacks

## How-To
```shell
helm version
# set helm repository
helm repo add stable https://charts.helm.sh/stable
# set jenkins repository
helm repo add jenkins https://charts.jenkins.io
# set bitnami
helm repo add bitnami https://charts.bitnami.com/bitnami

# search applications in repository
helm search repo

# download helm charts like below
helm pull bitnami/wordpress

# to get the chart README, execute the following command
helm inspect readme bitnami/wordpress

# to view the complete content of the chart, run below command
helm inspect all bitnami/wordpree | less

# to install application
helm install wordpress bitnami/wordpress --set service.type=NodePort
```

