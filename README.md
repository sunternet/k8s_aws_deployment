Load the Cloud Formation Template Provision.yaml in your AWS, it will:
1. Create a VPC to host the environment
2. Create a IAM Role with S3 RW for Master
3. Create a IAM Role with S3 RO for Nodes
4. Provisioning 1 VM for Master
5. Provisioning 2 VM for Nodes

# The following may change in different branch
Region: ap-southeast-1
AMI: Ubuntu 16.04
wget URL

# After Provisioning is done.
# On Master:
wget https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/master/1-CreateMaster.sh
sh -x 1-CreateMaster.sh

# After Master is in Ready Status (kubectl get node), On Nodes:
wget https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/master/2-CreateNodes.sh
sh -x ./2-CreateNodes.sh

# Cannot automate this in UserData since the script need to be run as non-root user "ubuntu"
# But the UserData can only be run as root

# If you need more Nodes, just "Run More Like This" and run the script on each nodes.