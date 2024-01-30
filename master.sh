#### update below source path to call common functions ####

#!/bin/bash

source /path/to/PROJECT-KUBEADM-AUTOMATION/common_func.sh

# Call functions with error checking
set_hostname "hostname" || { echo "Failed to set hostname"; exit 1; }
add_kubernetes_repo || { echo "Failed to add Kubernetes repo"; exit 1; }
install_dependencies "1.28.0" || { echo "Failed to install dependencies"; exit 1; }
configure_sysctl || { echo "Failed to configure sysctl"; exit 1; }
install_containerd || { echo "Failed to install containerd"; exit 1; }
add_hostname_config || { echo "Failed to set hostname"; exit 1; }
configure_containerd || { echo "Failed to configure containerd"; exit 1; }
initialize_kubernetes_cluster || { echo "Failed to initialize Kubernetes cluster"; exit 1; }
apply_weave_network || { echo "Failed to apply weave network"; exit 1; }
remove_taint_from_master || { echo "Failed to remove taint from master"; exit 1; }
generate_and_store_token || { echo "Failed to generate and store token"; exit 1; }
echo "Kubernetes installation completed successfully."
