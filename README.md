ProjectX
========

Development lifecycle automation learning project

Another Ansible sandbox with a number of objectives:

* Use Vagrant and Ansible to deliver a re-creatable (persistent) environment
* Explore the use of AWX to build and manage nodes
* Create a rudimentary CI/CD using Jenkins and Nexus
* Automate build and static checking of code
* Automate deployment (to AWS) and integration testing

The Vagrant script will spin up 3 CentOS machines on a private network:

* awx (192.168.100.101) - AWX control machine
* cicd  (192.168.100.102) - CD/CD node

Pre-requisites
--------------

* Virtual Box
* Cygwin
* Vagrant
* Vagrant plugin vagrant-vbguest
* Vagrant plugin vagrant-trigger

The Vagrantfile will spin up the VMs and install Ansible, ssh-keys etc. Script examples can be found in the **shared** directory.

```
vagrant up --no-parallel
vagrant ssh awx
```

AWX Roles
---------
The AWX node is built using the Ansible AWX role developed by [Guy Geerling](https://github.com/geerlingguy/ansible-role-awx). However, Guys roles stores the AWX database in the tmp directory, which means it will be deleted eventually. it also means that the Db will be recreated (lost) on every rebuild.

I have modified Guys ansible-role-awx to include being able to specify the DB directory location and to restore the DB from a Vagrant share.

AWX DB back up and restore
--------------------------
The AWX role has been modified to restore the AWX database when Vagrant builds nodes. This enables the nodes to be destroyed to save space when they are not needed but to be re-created with saved data as required.

To achive this there are two scripts in the shared/util directory:
* backup_awx_db.sh
* restore_awx_db.sh

backup_awx_db.sh is called by vagrant trigger before the awx node is destroyed. It backs up the previous AWX DB to a dated archive, copies the current AWX Postgres DB (pgdata directory) to the awx directory and cleans up any pid or marker files.

restore_awx_db.sh is called at the end of the Ansible install role script (again modified from Guys original). If this is not a fresh install i.e. there is a previous shared (vagrant)awx\pgdata directory, the script deletes the newly created AWX database, replaces it with the DB backed up in the shared vagrant awx directory. It needs to correct the owner and group of the DB files that are set to vagrant:vagrant by Windows and then restarts the docker containers.

This above approach was taken to re-use as many roles as possible to quickly get the project up and running. Also AWX cannot run an Ansible script against itself that effectively changes its own database, its a catch 22 situation.

Ansible Scripts
---------------
The ansible scripts used by AWX to build/maintain other nodes are held in the [ProjectX-Ansible repository](https://github.com/AgentCormac/ProjectX-Ansible).