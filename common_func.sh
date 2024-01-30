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
    yum install -y kubelet-${1} kubectl-${1} kubeadm-${1}
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
add_hostname_config() {
    cat >> /etc/hosts <<EOF
$(hostname -I | awk '{print $1}') $(hostname)
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
    kubectl taint node $(hostname) node-role.kubernetes.io/control-plane:NoSchedule-
}

# Function to generate and store Kubernetes token
generate_and_store_token() {
    kubeadm token generate > /root/.kube/token
    kubeadm token create $(</root/.kube/token) --print-join-command > /root/.kube/join_command
}

joining_as_node() {
    ${1}
}
