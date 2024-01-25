# PROJECT-KUBEADM-AUTOMATION
In this project, we are going to create kubernetes cluster 1.28 version through by using shell script in centos 8 server.

IN MASTER SERVER:-
Pull the code
add hostname in set_hostname function.
add kubernetes version in install_dependencies function.
and run the script ./master_node.sh


IN SLAVE SERVER:-
Pull the code
add hostname in set_hostname function.
update token in joining_as_node function(take from master server).
and run the script ./slave_node.sh
