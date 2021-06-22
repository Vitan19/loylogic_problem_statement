#! /bin/bash

sudo apt udpate
sudo install -y openjdk-8-jdk
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo apt install python
sduo apt install python-pip
sudo pip install boto boto3
sudo apt install ansible -y
