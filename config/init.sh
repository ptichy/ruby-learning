#!/bin/bash

echo "Install necessarry packages..."
sudo yum -y install ruby-devel
sudo yum -y install ruby22
sudo yum -y install ruby22-devel
sudo yum -y install gcc
sudo gem install bundler
sudo gem install io-console
sudo yum -y install nginx
sudo yum -y install git

git clone https://github.com/ptichy/ruby-learning.git
sudo mkdir -p /var/www
sudo cp -R ruby-learning /var/www/

cd ruby-learning
sudo cp config/nginx.conf /etc/nginx/
sudo cp config/unicorn /etc/init.d/
sudo chown -R ec2-user:nginx /var/www/ruby-learning/webapp

#set on autostart
sudo chkconfig --levels 3 nginx on
sudo chkconfig --levels 3 unicorn on

su - "ec2-user" -c "export BUNDLE_GEMFILE='/var/www/ruby-learning/webapp/Gemfile'; bundle install"

echo "Starting services..."
sudo service unicorn start
sudo service nginx start

echo "Init script done."

