#!/bin/bash
echo backing up AWX DB
echo archive previous DB
#silently fail mv if no current archive ie. fresh install
sudo mv -f /vagrant/awx/pgdata /vagrant/awx/pgdata-archive-$(date "+%Y%m%d%H%M%S") 2>/dev/null
echo archive current DB
sudo docker stop postgres
sudo cp -rf /opt/awx/pgdocker/pgdata /vagrant/awx
rm -f /vagrant/awx/*.pid
rm -f /vagrant/awx/ok.txt