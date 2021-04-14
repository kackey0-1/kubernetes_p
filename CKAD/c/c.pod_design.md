# Labels and annotations

## Create 3 pods with names nginx1,nginx2,nginx3. All of them should have the label app=v1
```bash
# kubectl run nginx1 --image=nginx --restart=Never --port 80 --dry-run=client -o yaml > nginx1.yaml
# kubectl run nginx2 --image=nginx --restart=Never --port 80 --dry-run=client -o yaml > nginx2.yaml
# kubectl run nginx3 --image=nginx --restart=Never --port 80 --dry-run=client -o yaml > nginx3.yaml
# # edit label name to app=v1 with vi editor
# kubectl apply -f nginx1.yaml
# kubectl apply -f nginx2.yaml
# kubectl apply -f nginx3.yaml
# kubectl delete pod --all

kubectl run nginx1 --image=nginx --restart=Never --port 80 --labels=app=v1
kubectl run nginx2 --image=nginx --restart=Never --port 80 --labels=app=v1
kubectl run nginx3 --image=nginx --restart=Never --port 80 --labels=app=v1
```

## Show all labels of the pods
```bash
kubectl get pod --show-labels
```

## Change the labels of pod 'nginx2' to be app=v2 [O]
```bash
kubectl label --overwrite pods nginx2 "app=v2"
```

## Get the label 'app' for the pods (show a column with APP labels) [O]
```bash
kubectl get po -l app --show-labels
```

## Get only the 'app=v2' pods [O]
```bash
kubectl get po -l app=v2 --show-labels
```

## Remove the 'app' label from the pods we created before
```bash
# add label
kubectl label pods --all app=v1
# remove label
kubectl label pods --all app-
```

## Create a pod that will be deployed to a Node that has the label 'accelerator=nvidia-tesla-p100'
```bash
kubectl run nginx4 --image=nginx --labels=accelrator=nvvidia-tesla-p100 --restart=Never
```

## Annotate pods nginx1, nginx2, nginx3 with "description='my description'" value
```bash
kubectl annotate pods nginx1 nginx2 nginx3 description='my description'
```

Check the annotations for pod nginx1
```bash
kubectl describe po nginx1 | grep -i annotation
```

## Remove the annotations for these three pods
```bash
kubectl annotate pods nginx1 nginx2 nginx3 description-
# better way
kubectl annotate po nginx{1..3} description-
```

## Remove these pods to have a clean state in your cluster
```bash
kubectl delete pods nginx1 nginx2 nginx3
# better way
kubectl delete po nginx{1..3}
```

# Deployment

## Create a deployment with image nginx:1.18.0, called nginx, having 2 replicas, defining port 80 as the port that this container exposes 
   (don't create a service for this deployment)
```bash
kubectl create deployment nginx --image=nginx:1.18.0 --replicas=2 --port=80 --output=yaml > deployment_nginx.yaml
kubectl get po,deploy --show-labels

# better way
kubectl create deployment nginx --image=nginx:1.18.0 --replicas=2 --port=80 --output=yaml > deployment_nginx.yaml
kubectl apply -f deployment_nginx.yaml
```

## View the YAML of this deployment
```bash
kubectl get deploy -o yaml > output_deployment.yaml
```

## View the YAML of the replica set that was created by this deployment
```bash
kubectl describe deploy nginx
# or
kubectl get rs -l app=nginx
```

## Get the YAML for one of the pods
```bash
kubectl get po -l app=nginx
kubectl get po <pod_name> -o yaml
```

## Check how the deployment rollout is going [NG]
```bash
kubectl describe deploy nginx | grep -i strategy
# should be
kubectl rollout status deploy nginx
```

## Update the nginx image to nginx:1.19.0
```bash
#cat deployment_nginx_upgrade.yaml ## update nginx tag to 1.19.0
#kubectl apply -f deployment_nginx_upgrade.yaml
## to check
#kubectl describe deploy nginx

kubectl edit deploy nginx # change nginx tag
# or 
kubectl set image deploy nginx nginx=1.19.2
```

## Check the rollout history and confirm that the replicas are OK
```bash
kubectk rollout history deploy nginx -o yaml

```

Undo the latest rollout and verify that new pods have the old image (nginx:1.7.8)

Do an on purpose update of the deployment with a wrong image nginx:1.91

Verify that something's wrong with the rollout

Return the deployment to the second revision (number 2) and verify the image is nginx:1.7.9

Check the details of the fourth revision (number 4)

Scale the deployment to 5 replicas

Autoscale the deployment, pods between 5 and 10, targetting CPU utilization at 80%

Pause the rollout of the deployment

Update the image to nginx:1.9.1 and check that there's nothing going on, since we paused the rollout
Resume the rollout and check that the nginx:1.9.1 image has been applied
Delete the deployment and the horizontal pod autoscaler you created

# Jobs
Create a job named pi with image perl that runs the command with arguments "perl -Mbignum=bpi -wle 'print bpi(2000)'"

Wait till it's done, get the output

Create a job with the image busybox that executes the command 'echo hello;sleep 30;echo world'

Follow the logs for the pod (you'll wait for 30 seconds)

See the status of the job, describe it and see the logs

Delete the job

Create a job but ensure that it will be automatically terminated by kubernetes if it takes more than 30 seconds to execute

Create the same job, make it run 5 times, one after the other. Verify its status and delete it

Create the same job, but make it run 5 parallel times

# Cron Job
## Create a cron job with image busybox that runs on a schedule of "*/1 * * * *" and writes 'date; echo Hello from the Kubernetes cluster' to standard output

## See its logs and delete it

## Create a cron job with image busybox that runs every minute and writes 'date; echo Hello from the Kubernetes cluster' to standard output. The cron job should be terminated if it takes more than 17 seconds to start execution after its schedule.

