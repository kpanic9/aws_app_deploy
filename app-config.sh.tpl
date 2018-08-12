#!/bin/bash

sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -ivh epel-release-latest-7.noarch.rpm
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo docker pull alexwhen/docker-2048
sudo docker run -d -p 80:80 alexwhen/docker-2048
