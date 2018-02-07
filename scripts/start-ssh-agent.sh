#!/bin/bash          
echo Start ssh-agent  
eval $(ssh-agent)
ssh-add /home/vagrant/.ssh/id_rsa
echo Ping all hosts
cd shared/ansible/test1
ansible  all -m ping -i hosts