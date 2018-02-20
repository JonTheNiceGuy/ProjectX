#!/bin/bash
echo backing up AWX DB
echo archive previous DB
sudo mv -f /vagrant/awx/pgdata /vagrant/awx/pgdata-archive-$(date "+%Y%m%d%H%M%S")
echo archive current DB
sudo docker stop postgres
sudo cp -rf /opt/awx/pgdocker/pgdata /vagrant/awx
rm -f /vagrant/awx/*.pid
rm -f /vagrant/awx/ok.txt