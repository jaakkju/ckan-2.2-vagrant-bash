ckan-2.2-vagrant-bash
=====================

Vagrant / Bash scripts to build up fresh CKAN 2.2 instance

Useful CKAN commands
----------------------

Activate Python Environment
 > . /usr/lib/ckan/default/bin/activate

List CKAN paster commands
paster --plugin=ckan --help

Add example user to CKAN
> paster --plugin=ckan user add example email=example@example.com --config=/etc/ckan/default/production.ini

Elevate user for CKAN user
> paster --plugin=ckan sysadmin add admin --config=/etc/ckan/default/production.ini

Load test data to CKAN
> paster --plugin=ckan create-test-data --config=/etc/ckan/default/production.ini

### Known issues
"An error occurred during installation of VirtualBox Guest Additions 4.3.10. Some functionality may not work as intended. windows"

https://github.com/mitchellh/vagrant/issues/3341

Connect to virtual box with ssh and run
> sudo ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions

Run vagrant 
> vagrant reload

Installation
------------
- Vbox: precise64
- Jetty, Apache 2.2, PostreSQL 9.1, Python Environment
- CKAN v. 2.2 - Package based installation
- CKAN Configuration file location 
	/etc/ckan/default/production.ini
	
