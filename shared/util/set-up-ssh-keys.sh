#!/bin/bash
echo Setting up common ssh-keys
echo Copying ssh keys from shared directory to vagrant user
sudo cp -rf /home/vagrant/shared/util/ssh-keys/.ssh /home/vagrant
sudo chown -R vagrant:vagrant /home/vagrant/.ssh
sudo chmod 700 /home/vagrant/.ssh
sudo chmod 600 /home/vagrant/.ssh/id_rsa
