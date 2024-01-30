#### update below source path to call common functions ####

#!/bin/bash

source /path/to/PROJECT-KUBEADM-AUTOMATION/common_func.sh

# Call functions with error checking
set_hostname "slave-node" || { echo "Failed to set hostname"; exit 1; }
add_kubernetes_repo || { echo "Failed to add Kubernetes repo"; exit 1; }
install_dependencies "1.28.0" || { echo "Failed to install dependencies"; exit 1; }
configure_sysctl || { echo "Failed to configure sysctl"; exit 1; }
install_containerd || { echo "Failed to install containerd"; exit 1; }
add_hostname_config || { echo "Failed to set hostname"; exit 1; }
configure_containerd || { echo "Failed to configure containerd"; exit 1; }
joining_as_node "kubeadm join master-ip:6443 --token ev94xn.gfqfolthmieagxmu --discovery-token-ca-cert-hash sha256:95ec8fda944bc66a7512e8e54deba8e90766f2ae63efa4fb41783e032c5cbeea"
echo "node has joined sucessfully"
