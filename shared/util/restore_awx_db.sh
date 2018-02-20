#!/bin/bash
if [ -d "/vagrant/awx/pgdata" ] 
then
    echo restoring up AWX DB
    echo stop containers
    sudo docker stop awx_web
    sudo docker stop postgres
    echo remove created DB
    sudo rm -rf /opt/awx/pgdocker/pgdata
    echo restore DB
    sudo cp -rf /vagrant/awx/pgdata /opt/awx/pgdocker/
    sudo chown -R polkitd:polkitd /opt/awx/pgdocker/pgdata
    sudo chgrp -R ssh_keys /opt/awx/pgdocker/pgdata/*
    echo start containers
    sudo docker start postgres
    sudo docker restart memcached
    sudo docker restart rabbitmq
    sudo docker restart awx_task
    sudo docker start awx_web
else
    echo "/vagrant/awx/pgdata does not exist"
    echo "Not attempting AWX DB restore. Treating as a fresh install."
fi