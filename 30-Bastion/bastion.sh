#!bin/bash

#we are creating 50gb root disk ,but only 20 is partitioned
# remaining dist we need to partition using the commands 

growpart /dev/nvme0n1 4
lvextend -r -L +30G /dev/mapper/RootVG-homeVol
xfs_growfs /home

yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform


#creating database

cd /home/ec2-user
git clone https://github.com/Ashish20004/roboshop_infra_dev.git
chown ec2-user:ec2-user -R roboshop-infra-dev
cd roboshop-infra-dev/40-databases
terraform init
terraform apply -auto-approve
