#!/usr/bin/env bash

echo "Updating apt"
apt-get update

echo "Installing auxiliary software"
apt-get install -y build-essential git nginx curl postgresql libpq-dev

echo "Installing rvm"
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm

echo "Installing ruby"
rvm requirements
rvm install 2.1

echo "Installing bundler"
gem install bundler

echo "Setting up retrospring"
cd /vagrant
export RAILS_ENV="production"
bundle install --deployment --without development test mysql
cp config/justask.yml.example config/justask.yml
cp config/database/yml.postgres config/database.yml

echo "Setting up database"
bundle exec rake db:setup RAILS_ENV=production

echo "Compiling assets"
bundle exec rake assets:precompile RAILS_ENV=production

echo "Setting up nginx"
cp docs/vagrant-nginx.conf /etc/nginx/sites-available/justask
service nginx restart

echo "Setting up foreman"
bundle exec foreman export -a retrospring -l /vagrant/log/ initscript /etc/init.d

echo "Starting foreman"
service retrospring start
