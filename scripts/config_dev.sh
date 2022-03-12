#!/bin/bash

source /scripts/util.sh

# stuff we want
yum_packages=(epel-release python36 python3-pip python36-devel java-11-openjdk gcc gcc-c++ make autoconf cmake wget tmux htop tig git traceroute nc nmap ncurses-devel ctags zlib-devel libffi-devel openssl-devel mlocate clang)
python3_packages=(pip ipython requests flake8 pycodestyle pylint ipython virtualenv pylint)

# TODO: THIS IS LIKE... REALLY REALLY INSECURE
github_key='235297140b5e3cfa028119e0e459e5d0e88042d0'

#cp -R /files/dotfiles/.* /home/vagrant
chown -R vagrant:vagrant /home/vagrant

# create a build space
mkdir /tmp/build

# main body
install_packages
clone_and_update_repos
install_rbenv
install_vim_8
install_YouCompleteMe

# clean up after ourselves
rm -rf /tmp/build

