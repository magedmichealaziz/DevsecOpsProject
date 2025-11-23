#!/bin/bash
# Update system
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y curl wget vim

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Configure sysctl
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Install container runtime (containerd)
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# Install kubeadm, kubelet, kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Initialize Kubernetes cluster
kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=$(hostname -I | awk '{print $1}') --upload-certs
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml