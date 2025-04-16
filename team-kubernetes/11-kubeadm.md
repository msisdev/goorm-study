# kubeadm

[Set up a kubernetes cluster on AWS EC2 using kubeadm](https://medium.com/@muppedaanvesh/set-up-a-kubernetes-cluster-on-aws-ec2-using-kubeadm-6e0244d8eff4)

[Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)


## VPC, EC2 Setup


Subnet
- `172.31.0.0/24` (example)














## EC2 with ubuntu

```bash
#!/bin/bash
sudo su
apt update

# docker
apt install -y docker.io

# kubernetes
apt install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet
```









## [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
```bash
kubeadm init --apiserver-advertise-address=<private-ip-of-control-plane> --pod-network-cidr=192.168.0.0/16

kubeadm init --apiserver-advertise-address=172.31.0.12 --pod-network-cidr=192.168.0.0/16
```

Save output, run at node
```
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.0.12:6443 --token hrawaq.y8zgmam4txv8ee1q \
        --discovery-token-ca-cert-hash sha256:546445755e7591de1bad4fa5e6ee1c870dcd8c5801b6d1c82906e64aa5cc2754
```

Get context
```bash
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl cluster-info
```

### reset `kubeadm init` or `kubeadm join`
```
kubeadm reset
```

Result
```
root@ip-172-31-0-12:/home/ubuntu# kubectl get node
NAME              STATUS   ROLES           AGE   VERSION
ip-172-31-0-102   Ready    <none>          16m   v1.32.3
ip-172-31-0-12    Ready    control-plane   17m   v1.32.3
```














## CNI
### [Calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises)
```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/tigera-operator.yaml

curl https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/custom-resources.yaml -O

kubectl create -f custom-resources.yaml

watch kubectl get pods -n calico-system
```

Result
```
Every 2.0s: kubectl get pods -n calico-system                                                 ip-172-31-0-12: Mon Apr 14 02:14:34 2025

NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-6cc764fdc7-c2jr4   1/1     Running   0          15s
calico-node-4r9zk                          0/1     Running   0          15s
calico-node-r46wm                          0/1     Running   0          15s
calico-typha-5b79954bbc-n4n7x              1/1     Running   0          16s
csi-node-driver-dnlkf                      2/2     Running   0          15s
csi-node-driver-xxh48                      2/2     Running   0          15s
```

Calico crashees cluster, so I replaced with flannel.

### [Flannel](https://github.com/flannel-io/flannel)
```
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

Result
```
root@ip-172-31-0-12:/home/ubuntu# kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
namespace/kube-flannel created

root@ip-172-31-0-12:/home/ubuntu# kubectl get all -n kube-flannel
NAME                        READY   STATUS             RESTARTS        AGE
pod/kube-flannel-ds-4nrgl   0/1     CrashLoopBackOff   7 (4m20s ago)   15m
pod/kube-flannel-ds-nfsx9   0/1     CrashLoopBackOff   7 (4m43s ago)   15m

NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/kube-flannel-ds   2         2         0       2            0           <none>          15m
```










## [metallb](https://metallb.io/installation/)

### Install
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml

namespace/metallb-system created

root@ip-172-31-0-12:/home/ubuntu# kubectl get deploy -n metallb-system -o wide
NAME         READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                               SELECTOR
controller   0/1     1            0           70s   controller   quay.io/metallb/controller:v0.14.9   app=metallb,component=controller
```

### [Config](https://mvallim.github.io/kubernetes-under-the-hood/documentation/kube-metallb.html)
The installation manifest does not include a configuration file. MetalLB’s components will still start, but will remain idle until you define and deploy a configmap. The memberlist secret contains the secretkey to encrypt the communication between speakers for the fast dead node detection.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: first-pool
      protocol: layer2
      addresses:
      - 172.31.0.100-172.31.0.200
```

```
kubectl apply -f ./metallb-config.yaml
```











## Run an App

### Deploy
```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

```
kubectl apply -f nginx-deployment.yaml
```


### Service
```yaml
# nginx-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-internal-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

```
kubectl apply -f nginx-service.yaml
```


### Load Balancer
```yaml
# nginx-loadbalancer-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-external-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

```
kubectl apply -f nginx-loadbalancer-service.yaml
```

```
root@ip-172-31-0-12:/home/ubuntu# kubectl get service nginx-external-service
NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
nginx-external-service   LoadBalancer   10.107.219.122   <pending>     80:30786/TCP   16s
```









## [MetalLB Compatibility](https://metallb.universe.tf/installation/clouds/)

In general, MetalLB is not compatible with cloud providers.
