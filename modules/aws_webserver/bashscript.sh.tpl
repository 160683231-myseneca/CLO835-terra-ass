#!/bin/bash

sudo yum -y update && sudo yum -y install iputils curl docker

sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -a -G docker ec2-user

aws s3 cp s3://bucket-sanah/script/docker-deploy.sh /home/ec2-user/docker-deploy.sh
chmod +x /home/ec2-user/docker-deploy.sh
/home/ec2-user/docker-script.sh