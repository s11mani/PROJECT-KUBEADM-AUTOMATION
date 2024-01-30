### PROJECT-KUBEADM-AUTOMATION ###
In this project, we are going to create kubernetes cluster(master and slave) version-1.28 by using shell script in centos 7 server.

### ### ### ### ### ###
IN MASTER SERVER :-
Pull the repo PROJECT-KUBEADM-AUTOMATION
IN master.sh
update source path ex:- /root/PROJECT-KUBEADM-AUTOMATION/common_func.sh
update hostname in set_hostname function.
give permission then run the run the script ./master.sh

### ### ### ### ### ###
IN SLAVE SERVER :-
Pull the repo PROJECT-KUBEADM-AUTOMATION
IN slave.sh
update source path ex:- /root/PROJECT-KUBEADM-AUTOMATION/common_func.sh
update hostname in set_hostname function.
update joining_as_node function with the token generated in master-server /root/.kube/join_command
give permission then run the run the script ./slave.sh

### ### ### ### ### ###
MAKE SURE NETWORK CONNECTIVITY IS ENABLED BETWEEN TWO SERVERS
