#Run on Master

#Disable swap, swapoff then edit your fstab removing any entry for swap partitions
#You can recover the space with fdisk. You may want to reboot to ensure your config is ok. 
swapoff -a
#vi /etc/fstab

#Add Google's apt repository gpg key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

#Add the Kubernetes apt repository
sudo bash -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF'

#Update the package list and use apt-cache to inspect versions available in the repository
sudo apt-get update
apt-cache policy kubelet | head -n 20 
apt-cache policy docker.io | head -n 20 

#Setup aws cli
sudo apt-get -y install python-pip
pip install awscli
aws configure set region ap-southeast-1

#Install the required packages, if needed we can request a specific version
sudo apt-get install -y docker.io kubelet kubeadm kubectl
sudo apt-mark hold docker.io kubelet kubeadm kubectl

#Check the status of our kubelet and our container runtime, docker.
#The kubelet will enter a crashloop until it's joined. 
# sudo systemctl status kubelet.service 
# sudo systemctl status docker.service 

#Ensure both are set to start when the system starts up.
sudo systemctl enable kubelet.service
sudo systemctl enable docker.service

#Download the yaml files for the pod network
# wget https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
wget https://docs.projectcalico.org/v3.11/manifests/calico.yaml

#The following is still needed?
# wget https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml

#Look inside calico.yaml and find the network range, adjust if needed.
#vi calico.yaml

#Create our kubernetes cluster, specifying a pod network range matching that in calico.yaml!
#--ignore-preflight-errors=NumCPU for AWS Free-Tie VM with only 1 vCPU
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=NumCPU

#Configure our account on the master to have admin access to the API server from a non-privileged account.
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Apply yaml files for your pod network
#kubectl apply -f rbac-kdd.yaml
kubectl apply -f calico.yaml

# Store the Master IP token and cert-hash to SQS which will be used by nodes later
# In FIFO order: masterip jointoken certhash
ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' > masterip
kubeadm token list | cut -d " " -f1 | tail -n 1 > jointoken
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' > certhash
# Get SQS Q URL, --queue-name can be get from script parameter
# aws sqs get-queue-url --queue-name k8s.fifo | grep QueueUrl | cut -d "\"" -f 4 > qurl
# Send to Q
# aws sqs send-message --queue-url `cat qurl` --message-body "`awk '{printf "%s",$0;printf "|"}' masterip jointoken certhash`" --message-deduplication-id "12345" --message-group-id "12345"
echo "run sudo kubeadm join $masterip:6443 --token $jointoken --discovery-token-ca-cert-hash sha256:$certhash on Nodes to join the cluster"

#Look for the all the system pods and calico pod to change to Running. 
#The DNS pod won't start until the Pod network is deployed and Running.
# kubectl get pods --all-namespaces

#Gives you output over time, rather than repainting the screen on each iteration.
# kubectl get pods --all-namespaces --watch

#All system pods should be Running
# kubectl get pods --all-namespaces

#Get a list of our current nodes, just the master.
# kubectl get nodes 

#Check out the systemd unit, and examine 10-kubeadm.conf
#Remeber the kubelet starts static pod manifests, and thus the core cluster pods
# sudo systemctl status kubelet.service 

#check out the directory where the kubeconfig files live
# ls /etc/kubernetes

#let's check out the manifests on the master
# ls /etc/kubernetes/manifests

#And look more closely at API server and etcd's manifest.
# sudo more /etc/kubernetes/manifests/etcd.yaml
# sudo more /etc/kubernetes/manifests/kube-apiserver.yaml
