#!/bin/bash

source /vagrant/scripts/util.sh

# stuff we want
yum_packages=(epel-release python34-pip gcc tmux htop tig git traceroute nc nmap python2-pip python-devel ncurses-devel ctags ShellCheck)
python_packages=('ipython>=5,<6' requests flake8 pycodestyle pylint ipython virtualenv)
python3_packages=(pylint)

# TODO: THIS IS LIKE... REALLY REALLY INSECURE
github_key='235297140b5e3cfa028119e0e459e5d0e88042d0'

cp -R /files/dotfiles/.* /home/vagrant
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

