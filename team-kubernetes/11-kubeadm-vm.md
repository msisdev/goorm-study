# kubeadm VM version

## Using Fedora Server

[Download Fedora Server](https://docs.fedoraproject.org/en-US/quick-docs/using-kubernetes-kubeadm/)

[Fedora Kubernetes Guide](https://docs.fedoraproject.org/en-US/quick-docs/using-kubernetes-kubeadm/)

### Before `kubeadm init`
Error
```
error execution phase kubelet-start: a Node with name "localhost.localdomain" and status "Ready" already exists in the cluster. You must delete the existing Node or change the name of this new joining Node
```

Check my ip
```
⋊> ~ ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d/ -f1
192.168.122.11
10.85.0.1
10.244.0.0
```

Change my hostname
```
⋊> ~ sudo hostnamectl set-hostname 192.168.122.11
⋊> ~ hostname
192.168.122.18
```

### Continue
```
$ sudo kubeadm init --pod-network-cidr=10.244.0.0/16

kubeadm join 192.168.122.11:6443 --token lgl4a1.0oaxboyxv8l076k3 \
	--discovery-token-ca-cert-hash sha256:50e16d777956572c4f4fbec5c4ee0eb98c05ab00fe93b2841d24307f17f926ad
```

Flannel
```
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
```
