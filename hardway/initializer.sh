#!/bin/zsh

# create worker instances
for i in 0 1 2; do
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --machine-type e2-standard-2 \
    --private-network-ip 10.240.0.1${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,controller
done

# create controller instances
for i in 0 1 2; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --machine-type e2-standard-2 \
    --metadata pod-cidr=10.200.${i}.0/24 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,worker
done

sleep 60

# deliver worker's certificate, private key, and root key
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp cert/ca.pem cert/${instance}-key.pem cert/${instance}.pem ${instance}:~/
done

# deliver controller's certificate, private key, and root key
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp cert/ca.pem cert/ca-key.pem cert/kubernetes-key.pem cert/kubernetes.pem \
    cert/service-account-key.pem cert/service-account.pem ${instance}:~/
done

# deliver worker's kubernetes config
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp cert/${instance}.kubeconfig cert/kube-proxy.kubeconfig ${instance}:~/
done

# deliver controller's kubernetes config
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp cert/admin.kubeconfig cert/kube-controller-manager.kubeconfig cert/kube-scheduler.kubeconfig ${instance}:~/
done

# deliver encryption config
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp config/encryption-config.yaml ${instance}:~/
done

# deliver controller's etcd initializer
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp bin/bootstrap-etcd.sh bin/bootstrap-kubernetes-controllers.sh ${instance}:~/
done

# deliver worker's initializer
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp bin/bootstrap-kubernetes-workers.sh ${instance}:~/
done


