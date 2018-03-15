################################################################
#
# Authors:      Mark Higginbottom, Jon Spriggs
#
# Date:		02/02/2018 - 13/03/2018
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
#     vagrant plugin install vagrant-vbguest
#################################################################

Vagrant.configure("2") do |config|
  config.vm.define "awx" do |awx|
    awx.vm.box = "bento/centos-7.4"
    awx.vm.hostname = 'awx.lan'

    awx.vm.network "public_network", bridge: "enp0s25", :use_dhcp_assigned_default_route => true

    awx.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--name", "awx"]
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--description", "AWX/Tower server"]
      v.customize ['sharedfolder', 'add', :id, '--name', 'awx-postgres', '--hostpath', File.dirname(__FILE__) + "/awx-postgres"]
      v.customize ['sharedfolder', 'add', :id, '--name', 'awx-projects', '--hostpath', File.dirname(__FILE__) + "/awx-projects"]
                                                                        #define the shared path to be persistently added
    end

    # This block mounts the postgres file system into your Vagrant path.
    awx.vm.provision "shell", inline: <<-SHELL
      grep "awx-postgres" /etc/fstab 2>/dev/null || echo "awx-postgres /opt/awx-postgres vboxsf _netdev,uid=999,gid=0,dmask=0077,fmask=0177 0 0" >> /etc/fstab
      grep "awx-projects" /etc/fstab 2>/dev/null || echo "awx-projects /opt/awx-projects vboxsf _netdev,uid=999,gid=0,dmask=0077,fmask=0177 0 0" >> /etc/fstab
      mkdir -p /opt/awx-{postgres,projects}
      chown -R 999:0 /opt/awx-{postgres,projects}
      mount -a
      touch /opt/awx-postgres/pgdocker-loop
      # Based on https://stackoverflow.com/a/5920355
      if [ $(wc -c <"/opt/awx-postgres/pgdocker-loop") -le 1024 ]; then
        # Based on https://invent.life/nesity/create-a-loopback-device-with-ext4/
        truncate --size 1024M /opt/awx-postgres/pgdocker-loop
        mkfs.ext4 -F /opt/awx-postgres/pgdocker-loop
      fi
      grep "pgdocker" /etc/fstab || echo "/opt/awx-postgres/pgdocker-loop /opt/awx-postgres/pgdocker auto loop,_netdev 0 0" >> /etc/fstab
      mkdir -p /opt/awx/pgdocker
      mount -a
    SHELL

    #Ansible provisioning from playbook that is on the Guest VM
    awx.vm.provision "ansible_local" do |ansible|
      ansible.verbose = "true"
      ansible.install = "true"
      ansible.extra_vars = {servers: "awx", postgres_data_dir: "/opt/awx-postgres/pgdocker", project_data_dir: "/opt/awx-projects"}
      ansible.galaxy_role_file = "awx/requirements.yml" #pre-provision any ansible roles before running the main playbook
      ansible.playbook = "awx/site.yml"
    end
  end

####################################################################################################################
####################################################################################################################
####################################################################################################################

#CICD provisioning to be carried out by AWX
#
#!!there may well be a timing issue here?
#
#
#  ##CI/CD VM
#  config.vm.define "cicd" do |cicd|
#    cicd.vm.box = "bento/centos-7.4"
#    cicd.vm.hostname = 'cicd'
#
#    cicd.vm.network :private_network, ip: "192.168.100.102"
#    cicd.vm.network :forwarded_port, guest: 22, host: 10222, id: "ssh"
#
#    cicd.vm.provider :virtualbox do |v|
#      v.customize ["modifyvm", :id, "--name", "cicd"]
#      v.customize ["modifyvm", :id, "--memory", 2048]
#      v.customize ["modifyvm", :id, "--description", "CI/CD server - jenkins & nexus"]
#      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]	#turn on host DNS resolver
#      v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]			#turn on DNS on VM in case of host dns problem
#      v.customize ['modifyvm', :id, '--cableconnected1', 'on']		#make sure "cables connected for VM network interfaces
#    end
#
#	#map shared directory
#	  #cicd.vm.synced_folder "shared", "/home/vagrant/shared", type: "virtualbox"
#	  #cicd.vm.synced_folder "shared", "/home/vagrant/cicd", type: "virtualbox"
#	  cicd.vm.synced_folder "shared", "/home/vagrant/shared", type: "nfs", linux__nfs_options: ['rw','no_subtree_check','all_squash','async']
#	  cicd.vm.synced_folder "shared", "/home/vagrant/cicd", type: "nfs", linux__nfs_options: ['rw','no_subtree_check','all_squash','async']
#	##run info script
#    cicd.vm.provision "info", type: "shell", path: "scripts/vminfo.sh"  
#	##run ssh-key setup script
#    cicd.vm.provision "info", type: "shell", path: "scripts/ssh-keys.sh"  
#
#  end
#  # backup up GUEST DB files before the guest is destroyed
#  config.trigger.before :destroy, :vm => ["cicd"] do
#    run_remote "shared/util/backup_jenkins_db.sh"
#  end
####################################################################################################################
####################################################################################################################
####################################################################################################################
#
#  
#  # clean up files on the host after the guest is destroyed
#  config.trigger.after :destroy do
#    run "scripts\\reset_known_hosts.bat"
#  end
end
