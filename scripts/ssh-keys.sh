#set up ssh keys for vagrant user
sudo cp -rf /home/vagrant/shared/ssh-keys/.ssh /home/vagrant
sudo chown -R vagrant:vagrant /home/vagrant/.ssh
sudo chmod 700 /home/vagrant/.ssh
sudo chmod 600 /home/vagrant/.ssh/id_rsa
echo .
echo These are the ssh keys to access this VM.
echo There should be the vagrant public key and the control public key.
cat /home/vagrant/.ssh/authorized_keys
#No longer needed
#eval $(ssh-agent)
#ssh-add /home/vagrant/.ssh/id_rsa
