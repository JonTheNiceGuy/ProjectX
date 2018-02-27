#!/bin/bash
echo backing up Jenkins DB
echo archive previous DB
#silently fail mv if no current archive ie. fresh install
sudo mv -f /vagrant/cicd/jenkins /vagrant/cicd/jenkins-archive-$(date "+%Y%m%d%H%M%S") 2>/dev/null
echo archive current DB
sudo service jenkins stop
sudo rm -f /var/lib/jenkins/jenkins.log
sudo cp -rf /var/lib/jenkins /vagrant/cicd