#!/bin/bash

# stuff we want
yum_packages=(epel-release gcc tmux git python2-pip python-devel ncurses-devel ctags)
python_packages=('ipython>=5,<6' requests pylint)

for package in ${yum_packages[@]}; do
  yum install -y $package
done

for package in ${python_packages[@]}; do
  pip install $package
done

cp -R /files/. /home/vagrant
chown -R vagrant:vagrant /home/vagrant

# create a build space
mkdir /tmp/build

# rbenv, because Ruby is hard enough
su -l vagrant -c 'git clone https://github.com/rbenv/rbenv.git ~/.rbenv; echo export PATH="$HOME/.rbenv/bin:$PATH" >> ~/.bash_profile; ~/.rbenv/bin/rbenv init'
cd /tmp/build
git clone https://github.com/rbenv/ruby-build.git
cd ruby-build
PREFIX=/usr/local ./install.sh

# We need to compile vim to make YouCompleteMe happy
cd /tmp/build
git clone https://github.com/vim/vim
cd vim
./configure --with-features=huge \
            --enable-multibyte \
            --enable-pythoninterp=yes \
            --with-python-config-dir=/lib64/python2.7/config \
            --enable-cscope
make
make install

# YCM pre-reqs
yum install -y xbuild go tsserver node npm cargo cmake centos-release-scl

yum install -y devtoolset-6

scl enable devtoolset-6 bash

# Install YCM in the context of our vagrant user
su -l vagrant -c 'source /opt/rh/devtoolset-6/enable; cd /home/vagrant/.vim/bundle; git clone https://github.com/Valloric/YouCompleteMe.git; cd YouCompleteMe; git submodule update --init --recursive; ./install.py --all'

# clean up after ourselves
rm -rf /tmp/build
