#!/bin/bash

source /vagrant/scripts/util.sh

# stuff we want
yum_packages=(epel-release python34-pip gcc tmux htop tig git traceroute nc nmap python2-pip python-devel)
python_packages=('ipython>=5,<6' click netaddr python-nmap paramikao pynetbox)
repos=(Network)

# TODO: THIS IS LIKE... REALLY REALLY INSECURE
github_key='235297140b5e3cfa028119e0e459e5d0e88042d0'

# create a build space
mkdir /tmp/build

# main body
install_packages
clone_and_update_repos

# clean up after ourselves
rm -rf /tmp/build

#####
ln -s /repo/Network/util/netbox/ipcheck/ipcheck.py /usr/local/bin/ipcheck.py
