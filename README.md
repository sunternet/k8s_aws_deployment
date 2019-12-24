
Provisioning 3 Ubuntu 16.04 Free-Tier VMs in EC2
# set hostname when create VM. //Don't know how
# Note, hostname cannot have "_". Must be a DNS-1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*')
# Make sure your VM hostname can be resolved

# On Master
wget https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/master/1-CreateMaster.sh
sh -x ./1-CreateMaster.sh

# On Nodes
wget https://raw.githubusercontent.com/sunternet/k8s_aws_deployment/master/2-CreateNodes.sh
sh -x ./2-CreateNodes.sh

# On Cloud