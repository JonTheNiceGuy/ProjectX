#!/bin/bash
#Ansible script may run multiple times. To make sure we dont restore the DB each time check for a marker file
#This keeps the script indempotent.
if [ ! -e "/var/lib/jenkins/restored.txt" ]
then
    echo "clean fresh jenkins DB, lets check to see if there is a restore point"
    if [ -d "/vagrant/cicd/jenkins" ] 
    then
        echo restoring Jenkins DB
        echo stop Jenkins
        sudo service jenkins stop
        echo remove created DB
        sudo rm -rf /var/lib/jenkins
        echo restore DB
        sudo cp -rf /vagrant/cicd/jenkins /var/lib/
        sudo chown -R jenkins:jenkins /var/lib/jenkins
        echo start jenkins
        sudo service jenkins start
        echo $(date "+%Y%m%d%H%M%S") >> /var/lib/jenkins/restored.txt
    else
        echo "/vagrant/cicd/jenkins does not exist"
        echo "Not attempting Jenkins DB restore. Treating as a fresh install."
        echo "Jenkins DB intitialised "$(date "+%Y%m%d%H%M%S") > /var/lib/jenkins/restored.txt
    fi
fi