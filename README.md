
Load the Cloud Formation Template in your AWS, it will:
1. Create a VPC to host the environment
2. Create a IAM Role with S3 RW for Master
3. Create a IAM Role with S3 RO for Nodes
4. Provisioning 1 Ubuntu 16.04 VM for Master
5. Provisioning 1 Ubuntu 16.04 VM for Nodes

# On Master:
# Cannot automate this in UserData since the script need to be run as non-root user "ubuntu"
# But the UserData can only be run as root
wget https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/ubt18/1-CreateMaster.sh
sh -x 1-CreateMaster.sh

# After Master is in Ready Status (kubectl get node), On Nodes:
wget https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/ubt18/2-CreateNodes.sh
sh -x ./2-CreateNodes.sh
