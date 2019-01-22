install_packages() {
  for package in ${yum_packages[@]}; do
    yum install -y $package
  done
  
  for package in ${python_packages[@]}; do
    pip install $package
  done
  
  for package in ${python3_packages[@]}; do
    pip3 install $package
  done
}

clone_and_update_repos() {
  safe_clone() {
    if [ ! -d $1 ]; then
      git clone  "https://jonathanm:${github_key}@github.doubleverify.com/jonathanm/${1}.git"
    fi
  }
  
  if [ -d /repo ]; then
    for repo in ${repos[@]}; do
      safe_clone ${repo}
      reponame=$(echo ${repo} | sed -e 's/^.*\/\([^.]*\)\..*$/\1/g')
      cd ${reponame}
      git pull
      cd ..
    done
  fi
}

install_rbenv() {
  su -l vagrant -c 'if [ ! -d ~/.rbenv ]; then git clone https://github.com/rbenv/rbenv.git ~/.rbenv; echo export PATH="$HOME/.rbenv/bin:$PATH" >> ~/.bash_profile; ~/.rbenv/bin/rbenv init; fi'
  cd /tmp/build
  git clone https://github.com/rbenv/ruby-build.git
  cd ruby-build
  PREFIX=/usr/local ./install.sh
}

install_vim_8() {
  vim_ver=$(/usr/local/bin/vim --version | grep 'VIM - .*[0-9]\.[0-9]' | sed 's/^[^0-9]*\([0-9]\)\..*$/\1/')
  
  #   speed up 'vagrang provision' with a quick check 
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
} 

install_YouCompleteMe() {
# YCM pre-reqs
yum install -y xbuild go tsserver node npm cargo cmake centos-release-scl
yum install -y devtoolset-6
scl enable devtoolset-6 bash

# Install YCM in the context of our vagrant user
su -l vagrant -c 'source /opt/rh/devtoolset-6/enable; cd /home/vagrant/.vim/bundle; if [ ! -d YouCompleteMe ]; then git clone https://github.com/Valloric/YouCompleteMe.git; cd YouCompleteMe; git submodule update --init --recursive; ./install.py --all; fi' 
}
