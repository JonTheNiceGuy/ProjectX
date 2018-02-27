################################################################
#
# Author: 	Mark Higginbottom
#
# Date:		02/02/2018
#
# Vagrant PROJECT file to create Ansible AWX provisioned VM on VirtualBox
#
# This vagrant file creates a centos/7 box on Virtual box and then
# bootstraps Ansible to buils the stack. The boot strap ansible script 
# is in shared\ansible\site.yml
# 
# shared directory is mapped to VM -> /home/vagrant/shared
#
# Dependencies:
#     vagrant plugin install vagrant-triggers
#     vagrant plugin install vagrant-vbguest
#################################################################
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'


Vagrant.configure("2") do |config|
  config.ssh.insert_key = false

##awx VM
  config.vm.define "awx" do |awx|
    #awx.vm.box = "centos/7"
    awx.vm.box = "bento/centos-7.4"
    awx.vm.hostname = 'awx'

    awx.vm.network :private_network, ip: "192.168.100.101"
    awx.vm.network :forwarded_port, guest: 22, host: 10122, id: "ssh"
    awx.vm.network :forwarded_port, guest: 7272, host: 7272, id: "awxtestport"

	#VirtualBox configuration
    awx.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--name", "awx"]
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--description", "AWX/Tower server"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]	#turn on host DNS resolver
      v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]			#turn on DNS on VM in case of host dns problem
	    v.customize ['modifyvm', :id, '--cableconnected1', 'on']		#make sure "cables connected for VM network interfaces
# Show VM?
#	  v.gui = true
    end

	#map shared directory
###built with
  #awx.vm.synced_folder "shared", "/home/vagrant/shared", type: "virtualbox"
  #awx.vm.synced_folder "awx", "/home/vagrant/shared", type: "virtualbox"
  awx.vm.synced_folder "shared", "/home/vagrant/shared"
  #map to tmp while unpodified amx role stores its db
  #awx.vm.synced_folder "awx/", "/tmp/pgdocker"


	awx.vm.provision "shell", inline: <<-SHELL
		ls -al shared
		#Basic vanilla installation to bootstrap Ansible.
		#set ownership of shared directory to vagrant
		sudo chown -R vagrant:vagrant /home/vagrant/shared
		##Install Ansible on awx node
		#sudo apt-get update -y
		sudo yum update -y
		sudo yum install vim -y
		sudo yum install epel-release -y
		sudo yum install ansible -y
		sudo yum install yum-utils
		##Install Git
		sudo yum install git -y
		##Turn off ansible key checking
		export ANSIBLE_HOST_KEY_CHECKING=false
	SHELL

	##run info script
    awx.vm.provision "info", type: "shell", path: "scripts/vminfo.sh"

	##Ansible provisioning from playbook that is on the Guest VM
	awx.vm.provision "ansible_local" do |ansible|
		ansible.verbose = "true"
		ansible.extra_vars = {servers: "awx"} #inject the name of the server we want to apply this ansible config to.
		ansible.galaxy_role_file = "shared/ansible/requirements.yml" #pre-provision any ansible roles before running the main playbook
		ansible.playbook = "shared/ansible/site.yml"
    end

	#map to modified awx role data store directory
  #  awx.vm.synced_folder "awx/", "/opt/awx"

	  # backup up GUEST DB files before the guest is destroyed
    config.trigger.before :destroy, :vm => ["awx"] do
      run_remote "shared/util/backup_awx_db.sh"
    end
	  # clean up HOST files on the host after the guest is destroyed
    config.trigger.after :destroy do
      run "scripts\\reset_known_hosts.bat"
    end
  end

####################################################################################################################
####################################################################################################################
####################################################################################################################

#CICD provisioning to be carried out by AWX
#
#!!there may well be a timing issue here?
#

  ##CI/CD VM
  config.vm.define "cicd" do |cicd|
    cicd.vm.box = "bento/centos-7.4"
    cicd.vm.hostname = 'cicd'

    cicd.vm.network :private_network, ip: "192.168.100.102"
    cicd.vm.network :forwarded_port, guest: 22, host: 10222, id: "ssh"

    cicd.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--name", "cicd"]
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--description", "CI/CD server - jenkins & nexus"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]	#turn on host DNS resolver
      v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]			#turn on DNS on VM in case of host dns problem
  	  v.customize ['modifyvm', :id, '--cableconnected1', 'on']		#make sure "cables connected for VM network interfaces
    end

	#map shared directory
	  #cicd.vm.synced_folder "shared", "/home/vagrant/shared", type: "virtualbox"
	  #cicd.vm.synced_folder "shared", "/home/vagrant/cicd", type: "virtualbox"
	  cicd.vm.synced_folder "shared", "/home/vagrant/shared", type: "nfs", linux__nfs_options: ['rw','no_subtree_check','all_squash','async']
	  cicd.vm.synced_folder "shared", "/home/vagrant/cicd", type: "nfs", linux__nfs_options: ['rw','no_subtree_check','all_squash','async']
	##run info script
    cicd.vm.provision "info", type: "shell", path: "scripts/vminfo.sh"  
	##run ssh-key setup script
    cicd.vm.provision "info", type: "shell", path: "scripts/ssh-keys.sh"  

  end
  # backup up GUEST DB files before the guest is destroyed
  config.trigger.before :destroy, :vm => ["cicd"] do
    run_remote "shared/util/backup_jenkins_db.sh"
  end
####################################################################################################################
####################################################################################################################
####################################################################################################################

  
  # clean up files on the host after the guest is destroyed
  config.trigger.after :destroy do
    run "scripts\\reset_known_hosts.bat"
  end
end
