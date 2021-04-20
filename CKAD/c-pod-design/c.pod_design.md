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
kubectl get po,rs
```

## Undo the latest rollout and verify that new pods have the old image (nginx:1.7.8)
```bash
kubectl rollout undo deploy nginx
kubectl describe deploy nginx
kubeclt describe rs nginx
```

## Do an on purpose update of the deployment with a wrong image nginx:1.91
```bash
# 1.18 -> 1.91
kubectl edit deploy nginx 
kubectl describe deploy nginx
```

## Verify that something's wrong with the rollout
```bash
kubectl rollout status deploy nginx
```

## Return the deployment to the second revision (number 2) and verify the image is nginx:1.7.9
```bash
kubectl rollout undo deploy nginx --to-revision=2
kubectl describe deploy nginx | grep -i image
kubectl rollout status deploy nginx
```

## Check the details of the fourth revision (number 4)
```bash
kubectl describe rs nginx | egrep -i "revision|image"
# or 
kubectl rollout history deploy nginx 
kubeclt rollout history deploy nginx --revision=4
```

## Scale the deployment to 5 replicas
```bash
kubectl scale --replicas=5 deploy nginx
kubectl get po,rs,deploy
```

## Autoscale the deployment, pods between 5 and 10, targetting CPU utilization at 80%
```bash
kubectl autoscale deploy nginx --min=5 --max=10 --cpu-percent=80
kubectl describe deploy nginx
```

## Pause the rollout of the deployment
```bash 
kubectl rollout pause deploy nginx
```

## Update the image to nginx:1.19.1 and check that there's nothing going on, since we paused the rollout
```bash
kubectl edit deploy nginx
kubectl describe deploy nginx
kubectl rollout status deploy nginx
kubectl rollout history deploy nginx
```

## Resume the rollout and check that the nginx:1.19.1 image has been applied
```bash
kubectl rollout resume deploy nginx

kubectl rollout status deploy nginx 
kubectl rollout history deploy nginx --revision=<number>

kubectl get po,rs,deploy
# rs_name=nginx-xxxxxxx
kubectl describe rs/<rs_name>
```

## Delete the deployment and the horizontal pod autoscaler you created
```bash
kubectl delete deploy nginx
kubectl api-resources
kubectl delete horizontalpodautoscalers nginx
kubectl delete hpa nginx
```

# Jobs
## Create a job named pi with image perl that runs the command with arguments "perl -Mbignum=bpi -wle 'print bpi(2000)'"
```bash
kubectl create job pi --image=perl -- perl -Mbignum=bpi -wle 'print bpi(2000)'
```

## Wait till it's done, get the output
```bash
kubectl get jobs -w
```
## Create a job with the image busybox that executes the command 'echo hello;sleep 30;echo world'
```bash
kubectl create job busybox --image=busybox -- /bin/sh -c "echo hello;sleep 30;echo world"
```

## Follow the logs for the pod (you'll wait for 30 seconds)
```bash
#kubectl get jobs -w
kubectl get po 
kubectl logs busybox-<hash-value>
```

## See the status of the job, describe it and see the logs
```bash
kubectl describe job busybox
```

## Delete the job
```bash
kubectl get jobs
kubectl delete job busybox
```

## Create a job but ensure that it will be automatically terminated by kubernetes if it takes more than 30 seconds to execute
```bash
kubectl create job busybox --image=busybox --dry-run=client -o yaml -- /bin/sh -c "while true; do echo hello; sleep 10; done" > job.yaml
# vim job.yaml and add spec.activeDeadlineSeconds: 30 property
kubectl apply -f job.yaml
kubectl get job busybox -w
```
## Create the same job, make it run 5 times, one after the other. Verify its status and delete it
```bash
kubectl create job busybox --image=busybox --dry-run=client -o yaml -- /bin/sh -c "echo hello; sleep 10; echo world" > job.yaml
# vim job.yaml and add spec.completions: 5 property
kubectl apploy -f job.yaml
kubectl get job busybox -w
kubectl delete job busybox
```
## Create the same job, but make it run 5 parallel times
```bash
kubectl create job busybox --image=busybox --dry-run=client -o yaml -- /bin/sh -c "echo hello;sleep 10;echo world" > job_parallel.yaml
# vim job.yaml and add parallelism: 5 property
kubectl get job busybox -w
kubectl delete job busybox
```

# Cron Job
## Create a cron job with image busybox that runs on a schedule of "*/1 * * * *" and writes 'date; echo Hello from the Kubernetes cluster' to standard output
```bash
kubectl create cronjob busybox --image=busybox --schedule="*/1 * * * *" --dry-run=client -o yaml -- /bin/sh -c "data; echo 'Hello from the Kubernetes cluster'"
kubect get cj busybox
kubectl describe cj busybox

kubectl delete cj busybox
```

## See its logs and delete it
```bash
kubectl ge po
kubectl logs <pod_name>

kubectl delete cj busybox
```
## Create a cron job with image busybox that runs every minute and writes 'date; echo Hello from the Kubernetes cluster' to standard output. The cron job should be terminated if it takes more than 17 seconds to start execution after its schedule.
```bash
kubectl create cj busybox --image=busybox --schedule="*/1 * * * *" --dry-run=client -o yaml -- /bin/sh -c "date; echo 'Hello from Kubernetes cluster'" > cronjob_every_minute.yaml
# vim cronjob_every_minute.yaml and add spec.jobTemplate.spec.activeDeadlineSeconds: 17
kubectl apply -f cronjob_every_minute.yaml
kubectl get cj busybox -w
```