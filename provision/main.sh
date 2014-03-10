#!/bin/bash

this=${0##*/}
echo ":: Running Vagrant provisioning script $this"

echo ":: Installation errors will be logged to $this.log"
exec 2> >(tee -a /vagrant/$this.log >&2)

echo ":: Updating the package manager"
sudo apt-get update

echo ":: Setting locales"
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo locale-gen en_US.UTF-8

echo ":: Setting timezone to Europe/Helsinki"
sudo ln -sf /usr/share/zoneinfo/Europe/Helsinki /etc/localtime

echo ":: Installing dependencies available via apt-get"
sudo apt-get install -y nginx apache2 libapache2-mod-wsgi libpq5

if [ ! -f /home/vagrant/python-ckan_2.2_amd64.deb ]; then
	echo ":: Downloading the CKAN 2.2 package since not existing"
	wget -q http://packaging.ckan.org/python-ckan_2.2_amd64.deb
fi

echo ":: Installing the CKAN 2.2 package"
sudo dpkg -i /home/vagrant/python-ckan_2.2_amd64.deb

echo ":: Changing Apache 2 configuration for CKAN defaults"
sudo cp /vagrant/provision/apache2_ckan_default.conf /etc/apache2/sites-available/ckan_default

echo ":: Starting Apache2"
sudo service apache2 restart 

echo ":: Install postgresql-9.1, jetty and openjdk-6"
sudo apt-get install -y postgresql-9.1 solr-jetty openjdk-6-jdk

echo ":: Copying jetty configuration file"
sudo cp /vagrant/provision/jetty.conf /etc/default/jetty
sudo mkdir -p /var/lib/ckan/storage
sudo chown jetty:jetty -R /var/lib/ckan/

echo ":: Create a CKAN database in postgresql"
sudo -u postgres createuser -S -D -R ckan_default
sudo -u postgres psql -c "ALTER USER ckan_default PASSWORD 'pass'"
sudo -u postgres createdb -O ckan_default ckan_default

echo ":: Handling Solr schema files and copying CKAN configuration"
sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema-2.0.xml /etc/solr/conf/schema.xml
sudo cp /vagrant/provision/ckan.ini /etc/ckan/default/production.ini

echo ":: Starting Jetty"
sudo service jetty start

echo ":: Initialize CKAN database"
sudo ckan db init

echo ":: Creating an admin user"
source /usr/lib/ckan/default/bin/activate
paster --plugin=ckan user add admin email=admin@email.org password=pass -c /etc/ckan/default/production.ini
paster --plugin=ckan sysadmin add admin -c /etc/ckan/default/production.ini

echo ":: Running instance on 192.168.13.37"