#!/bin/bash

yum_packages=(
  epel-release
  gcc
  tmux
  git
  python2-pip
  python-devel
  ncurses-devel
  ctags
)

python_packages=(
  'ipython>=5,<6'
  requests
  flask
)

for package in ${yum_packages[@]}; do
  yum install -y $package
done

for package in ${python_packages[@]}; do
  pip install $package
done

echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

useradd -m flask

mkdir -p /home/flask/.ssh
cp /files/flask/flask.pri /home/flask/.ssh/id_rsa
chown -R flask:flask /home/flask/
chmod 600 /home/flask/.ssh/id_rsa

su -l flask -c 'git clone git@github.doubleverify.com:jonathanm/oren.git /tmp/oren'

mkdir /usr/local/flask
mv /tmp/oren /usr/local/flask/oren
