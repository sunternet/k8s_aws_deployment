# Infrastructure Provisioning
Make sure switching to your AWS ap-southeast-1 (Singapore) region. 

Follow the [CloudFormation Steps](./CloudFormation_Steps.jpg) to load the Cloud Formation Template "0-Provision.yaml", it will:
1. Create a VPC to host the environment
2. Create a IAM Role with SQS(Simple Queue Service) RW for Master and Nodes
3. Provisioning 1 VM for Master
4. Provisioning 3 VM for Nodes
5. Create a SQS Queue called "k8s.fifo" for transferring masterIP, jointoken, certhash from Master to Nodes

# Install Master
This will install a Master Node with Calico Network Plugin.

After Provisioning is done.

On Master:
```
wget https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/master/1-CreateMaster.sh
sh -x 1-CreateMaster.sh
```
Copy the last "sudo kubeadm join" command.

Verify Master is in Ready Status:
```
kubectl get node
kubectl get pods --all-namespaces
```
# Install Nodes
On Nodes:
```
wget https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/master/2-CreateNodes.sh
sh -x ./2-CreateNodes.sh
sudo kubeadm join ...
```
The "kubeadm join" is copied from master.

Back to Master, wait several minutes and verify Nodes are in Ready Status:
```
kubectl get node
```

# Install More Nodes
If you need more Nodes, just "Run More Like This" in AWS EC2 and run the [Install Nodes](#install-nodes) script on each nodes.

# You Are Done!

# Deploy Test App (Optional)
Below are Optional steps to run a Hello App in your k8s to test it's functionality.

Deploy the App
```
kubectl apply -f https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/master/3-DeployHelloApp.yml
```
Run a Service for the Deployment
```
kubectl apply -f https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/master/4-ServiceHelloApp.yml
```
Confirm the Service is running
```
kubectl get all
```
Use curl to your NodeIP:30000 to check the Application
```
curl http://<NodeIP:30000>
```
Delete the test App
```
kubectl delete deployment hello-world
kubectl delete service hello-world
```
# My Note
 The following may change in different branch
 - Region: ap-southeast-1
 -  AMI: Ubuntu 16.04
 -  GitHub Repo URL: https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/master