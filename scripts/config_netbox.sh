#!/bin/bash

yum_packages=(
  epel-release
  tmux
  git
  docker
  docker-compose
  python2-pip
  python-devel
  ncurses-devel
  ctags
)

python_packages=(
  'ipython>=5,<6'
  requests
  pynetbox
)

for package in ${yum_packages[@]}; do
  yum install -y $package
done

for package in ${python_packages[@]}; do
  pip install $package
done

echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

if [ ! -d docker-netbox ]; then
  git clone https://github.com/pitkley/docker-netbox.git
fi

cd docker-netbox

cp /files/netbox/docker-compose.yml .

systemctl start docker

docker-compose run --rm netbox createsuperuser
docker-compose up -d
