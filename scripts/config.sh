#!/bin/bash

# stuff we want
yum_packages=(epel-release python34-pip gcc tmux htop tig git traceroute nc nmap python2-pip python-devel ncurses-devel ctags)
python_packages=('ipython>=5,<6' requests flake8 pycodestyle pylint ipython virtualenv)
python3_packages=(pylint)
repos=(vagrant oren)

# TODO: THIS IS LIKE... REALLY REALLY INSECURE
github_key='235297140b5e3cfa028119e0e459e5d0e88042d0'

for package in ${yum_packages[@]}; do
  yum install -y $package
done

for package in ${python_packages[@]}; do
  pip install $package
done

for package in ${python3_packages[@]}; do
  pip3 install $package
done

cd /repo

safe_clone() {
  if [ ! -d $1 ]; then
    git clone  "https://jonathanm:${github_key}@github.doubleverify.com/jonathanm/${1}.git"
  fi
}

for repo in ${repos[@]}; do
  safe_clone ${repo}
done

cp -R /files/dotfiles/.* /home/vagrant
chown -R vagrant:vagrant /home/vagrant

# create a build space
mkdir /tmp/build

# rbenv, because Ruby is hard enough
su -l vagrant -c 'if [ ! -d ~/.rbenv ]; then git clone https://github.com/rbenv/rbenv.git ~/.rbenv; echo export PATH="$HOME/.rbenv/bin:$PATH" >> ~/.bash_profile; ~/.rbenv/bin/rbenv init; fi'
cd /tmp/build
git clone https://github.com/rbenv/ruby-build.git
cd ruby-build
PREFIX=/usr/local ./install.sh

# We need to compile vim to make YouCompleteMe happy
vim_ver=$(/usr/local/bin/vim --version | grep 'VIM - .*[0-9]\.[0-9]' | sed 's/^[^0-9]*\([0-9]\)\..*$/\1/')

# speed up 'vagrang provision' with a quick check
if [[ $vim_ver -lt 8 ]]; then
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
fi

# YCM pre-reqs
yum install -y xbuild go tsserver node npm cargo cmake centos-release-scl
yum install -y devtoolset-6
scl enable devtoolset-6 bash

# Install YCM in the context of our vagrant user
su -l vagrant -c 'source /opt/rh/devtoolset-6/enable; cd /home/vagrant/.vim/bundle; if [ ! -d YouCompleteMe ]; then git clone https://github.com/Valloric/YouCompleteMe.git; cd YouCompleteMe; git submodule update --init --recursive; ./install.py --all; fi'

# clean up after ourselves
rm -rf /tmp/build
