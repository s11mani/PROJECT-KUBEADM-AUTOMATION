#### To join centos-8 server as a slave node to centos master server using kubeadm ####
## get the token generated from master server and replace the token in joining_as_node function below.

#!/bin/bash

source /path/to/master_node.sh

joining_as_node() {
    ${1}
}

# Call functions with error checking
set_hostname "hostname" || { echo "Failed to set hostname"; exit 1; }
add_kubernetes_repo || { echo "Failed to add Kubernetes repo"; exit 1; }
install_dependencies "1.28.0" || { echo "Failed to install dependencies"; exit 1; }
configure_sysctl || { echo "Failed to configure sysctl"; exit 1; }
install_containerd || { echo "Failed to install containerd"; exit 1; }
add_hostname_config || { echo "Failed to set hostname"; exit 1; }
configure_containerd || { echo "Failed to configure containerd"; exit 1; }
joining_as_node "kubeadm join master-ip:6443 --token o8jg60.5duc9zsytr2whk7s --discovery-token-ca-cert-hash sha256:2b66152f23d1a3ec960c09f30fefcce509c475a31c7c763127bc2d23a1978d42" || { echo "Failed to join as a node"; exit 1; }
echo "node has joined sucessfully"
