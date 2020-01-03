# Infrastructure Provisioning
Switch to your AWS ap-southeast-1 (Singapore) region. Load the Cloud Formation Template "0-Provision.yaml", it will:
1. Create a VPC to host the environment
2. Create a IAM Role with SQS RW for Master
3. Create a IAM Role with SQS RO for Nodes
4. Provisioning 1 VM for Master
5. Provisioning 2 VM for Nodes
6. Create a SQS Q called "k8s.fifo" for transferring masterIP, jointoken, certhash from Master to Nodes

# Install Master
After Provisioning is done.

On Master:
```
wget https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/ubt16_sqs/1-CreateMaster.sh
sh -x 1-CreateMaster.sh
```
Verify Master is in Ready Status:
```
kubectl get node
kubectl get pods --all-namespaces
```
# Install Nodes
On Nodes:
```
wget https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/ubt16_sqs/2-CreateNodes.sh
sh -x ./2-CreateNodes.sh
```
Back to Master, wait several minutes and verify Nodes are in Ready Status:
```
kubectl get node
```

# Install More Nodes
If you need more Nodes, just "Run More Like This" in AWS EC2 and run the script on each nodes.

# You Are Done!

# Deploy Test App (Optional)
Below are Optional steps to run a Hello App in your k8s to test it's functionality.

Deploy the App
```
kubectl apply -f https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/ubt16_sqs/3-DeployHelloApp.yml
```
Run a Service for the Deployment
```
kubectl apply -f https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/ubt16_sqs/4-ServiceHelloApp.yml
```
Confirm the Service is running
```
kubectl get all
```
Use curl to your service Cluster-IP to check the Application
```
curl http://<Cluster-IP>
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
 -  GitHub Repo URL: https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/ubt16_sqs