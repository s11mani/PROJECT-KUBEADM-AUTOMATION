#!/bin/bash

# Function to set host-name
set_hostname() {
    hostnamectl set-hostname ${1}
}

# Function to add Kubernetes repository
add_kubernetes_repo() {
    tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
}

# Function to install system dependencies and Kubernetes components
install_dependencies() {
    yum clean all && yum -y makecache
    yum -y install epel-release vim git curl wget
    yum install -y kubelet-1.28.0 kubectl-1.28.0 kubeadm-1.28.0
    setenforce 0
    sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    swapoff -a
    modprobe overlay
    modprobe br_netfilter
}

# Function to configure sysctl for Kubernetes
configure_sysctl() {
    tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
    sysctl --system
}

# Function to install containerd runtime
install_containerd() {
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y containerd.io
    lsmod
    systemctl enable kubelet
}

# Function to set hostname
set_hostname() {
    cat >> /etc/hosts <<EOF
${1} ${2}
EOF
}

# Function to configure containerd for Kubernetes
configure_containerd() {
    cat > /etc/containerd/config.toml <<EOF
[plugins."io.containerd.grpc.v1.cri"]
  systemd_cgroup = true
EOF
    systemctl restart containerd
    systemctl enable containerd
    crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock
}

# Function to initialize Kubernetes cluster
initialize_kubernetes_cluster() {
    kubeadm config images pull
    kubeadm init --pod-network-cidr=10.244.0.0/16
    rm -rf /root/.kube/
    mkdir -p /root/.kube/
    cp -i /etc/kubernetes/admin.conf /root/.kube/config
    chown $(id -u):$(id -g) /root/.kube/config
}

# Function to apply Weave network
apply_weave_network() {
    kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
}

# Function to remove taint from master node
remove_taint_from_master() {
    kubectl taint node "${1}" node-role.kubernetes.io/control-plane:NoSchedule-
}

# Function to generate and store Kubernetes token
generate_and_store_token() {
    kubeadm token generate > /root/.kube/token
    kubeadm token create $(</root/.kube/token) --print-join-command > /root/.kube/join_command
}



# Call functions with error checking
set_hostname "host-name" || { echo "Failed to set hostname"; exit 1; }
add_kubernetes_repo || { echo "Failed to add Kubernetes repo"; exit 1; }
install_dependencies || { echo "Failed to install dependencies"; exit 1; }
configure_sysctl || { echo "Failed to configure sysctl"; exit 1; }
install_containerd || { echo "Failed to install containerd"; exit 1; }
set_hostname "10.10.10.10" "hostname" || { echo "Failed to set hostname"; exit 1; }
configure_containerd || { echo "Failed to configure containerd"; exit 1; }
initialize_kubernetes_cluster || { echo "Failed to initialize Kubernetes cluster"; exit 1; }
apply_weave_network || { echo "Failed to apply weave network"; exit 1; }
remove_taint_from_master "pppp" || { echo "Failed to remove taint from master"; exit 1; }
generate_and_store_token || { echo "Failed to generate and store token"; exit 1; }
echo "Kubernetes installation completed successfully."
