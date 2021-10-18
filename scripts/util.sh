GITHUB_SERVER='https://github.com'
NOTHINGHERE='/files/handshake.tgz'
BUILDDIR='build'

install_packages() {
  #yum update -y

  for package in "${yum_packages[@]}"; do
    yum install -y "$package"
  done

  alternatives --set python /usr/bin/python3

  python --version
  pip3 --version

  for package in "${python_packages[@]}"; do
    pip install --upgrade "$package"
  done

  for package in "${python3_packages[@]}"; do
    pip3 install --upgrade "$package"
  done
  # ShellCheck by hand
  sc_url="https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz"

  curl -LJO "$sc_url" > sc.txz
  tar xvJf sc.txz
  cp shellcheck-stable/shellcheck /usr/local/bin
}

clone_and_update_repos() {
  echo "updating repos: pwd=$(pwd)"
  echo "ls=$(ls /vagrant)"
  echo "gh_base=${GITHUB_SERVER}"
  echo "key_path=${NOTHINGHERE}"
  echo "builddir=${BUILDDIR}"
  echo "ip=$(ip address)"

  # FIX: THIS IS ALL A DIRTY HACK

  ##  ALL this misery has been caused because you're running as root, in /home/vagrant
  #   so when you add shit to '~' like host keys, they end up in the wrong place. fml

#  safe_clone() {
#    if [ ! -d $1 ]; then
#      #git clone  "https://jonathanm:${github_key}@github.doubleverify.com/jonathanm/${1}.git"
#      true
#    fi
#  }

  mkdir $BUILDDIR
  chown vagrant:vagrant $BUILDDIR
  cd $BUILDDIR

  cp ${NOTHINGHERE} .
  tar xvzf ${NOTHINGHERE}
  chown vagrant:vagrant handshake
  chmod 600 handshake

#  echo 'trying to fucking add github.com to my fucking key store.'
#  set -x
  mkdir -p /home/vagrant
su vagrant <<'EOF'
  pwd
  chown vagrant:vagrant -R /home/vagrant/.ssh
  mkdir /home/vagrant/.ssh
  ssh-keyscan github.com >> /home/vagrant/.ssh/known_hosts
  ssh-agent bash -c 'ssh-add handshake; git clone git@github.com:jonmccreery/profile.git'
  cd profile
  ./deploy.sh
EOF
#  set +x
  # <------ LESS DIRTY FROM HERE

#  if [ -d /repo ]; then
#    for repo in ${repos[@]}; do
#      safe_clone ${repo}
#      reponame=$(echo "${repo}" | sed -e 's/^.*\/\([^.]*\)\..*$/\1/g')
#      cd ${reponame}
#      git pull
#      cd ..
#    done
#  fi
}

install_rbenv() {
  su -l vagrant -c 'if [ ! -d ~/.rbenv ]; then git clone https://github.com/rbenv/rbenv.git ~/.rbenv; echo export PATH="$HOME/.rbenv/bin:$PATH" >> ~/.bash_profile; ~/.rbenv/bin/rbenv init; fi'
  cd /tmp/build
  git clone https://github.com/rbenv/ruby-build.git
  cd ruby-build
  PREFIX=/usr/local ./install.sh
}

install_vim_8() {
  #   speed up 'vagrant provision' with a quick check 
  if [ -f /usr/local/bin/vim ]; then
    vim_ver=$(/usr/local/bin/vim --version | grep 'VIM - .*[0-9]\.[0-9]' | sed 's/^[^0-9]*\([0-9]\)\..*$/\1/')
  fi

  if [[ $vim_ver -lt 8 ]]; then
      cd /tmp/build
      git clone https://github.com/vim/vim
      cd vim
      #  with-features=huge      set most optional stuff to enabled
      #  enable-multibyte        unicode ftw
      #  enable-pythoninterp     hell yes
      #  enable-cscope           for tags
      ./configure --with-features=huge \
                  --enable-multibyte \
                  --enable-python3interp \
                  --with-python-config-dir=/lib64/python2.7/config \
                  --enable-cscope
      make
      make install
  fi
}

install_YouCompleteMe() {
  # YCM pre-reqs
  yum install -y libarchive go nodejs npm cargo cmake 
  yum install -y devtoolset-6
  scl enable devtoolset-6 bash

  # Install YCM in the context of our vagrant user
  read -r -d '' install_ycm_cmd  <<-'EOF'
source /opt/rh/devtoolset-6/enable
cd /home/vagrant/.vim/bundle

rm -rf YouCompleteMe
git clone https://github.com/Valloric/YouCompleteMe.git
cd YouCompleteMe
git submodule update --init --recursive
EXTRA_CMAKE_ARGS=-DEXTERNAL_LIBCLANG_PATH=/usr/lib64/libclang.so ./install.py --system-libclang --clang-completer --go-completer --java-completer --rust-completer --ts-completer
EOF

  su -l vagrant -c "${install_ycm_cmd}"
}
