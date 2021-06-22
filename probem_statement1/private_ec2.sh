#! /bin/bash

sudo apt update
wget http://apache.spinellicreations.com/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz
tar -xvzf apache-tomcat-8.5.32.tar.gz
sudo apt install -y openjdk-8-jdk
sudo apt install -y python3
