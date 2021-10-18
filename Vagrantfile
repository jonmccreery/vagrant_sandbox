nodes = [
  # here be the box definitions
  {
    :hostname  => 'dev-cent8',
    :cpus      => 3,
    :memory    => 2048,
    :ip        => '192.168.0.10',
    :boxfile   => 'mgv/centos-8-vbguest',
    #:boxfile   => 'centos/8',
    :script    => 'scripts/config_dev.sh',
    :autostart => true,
  },
  {
    :hostname  => 'oren',
    :ip        => '192.168.0.50',
    :boxfile   => 'centos/7',
    :script    => 'scripts/config_oren.sh',
    :autostart => true,
    :port_map  => { 8080 => 5000 }
  },
  {
    :hostname  => 'kali',
    :boxfile   => 'offensive-security/kali-linux',
    :script    => 'scripts/config.sh',
    :autostart => true,
  },
  {
    :hostname  => 'blank',
    :ip        => '192.168.0.51',
    :boxfile   => 'centos/7',
    :autostart => true,
  },
  {
    :hostname  => 'netbox',
    :ip        => '192.168.0.52',
    :port_map  => { 8000 => 8000 },
    :script    => 'scripts/config_netbox.sh',
    :boxfile   => 'centos/7',
    :autostart => true,
  },
  {
    :hostname  => 'ipcheck',
    :ip        => '192.168.0.53',
    :script    => 'scripts/config_ipcheck.sh',
    :boxfile   => 'centos/7',
    :autostart => true,
  },
  {
    :hostname  => 'dev-ubuntu14',
    :ip        => '192.168.0.54',
    :boxfile   => 'ubuntu/trusty64',
    :autostart => true,
  },
  {
    :hostname  => 'dev-ubuntu16',
    :ip        => '192.168.0.54',
    :boxfile   => 'ubuntu/xenial64',
    :autostart => true,
  }
]


Vagrant.configure("2") do |config|
  # keep our insecure key.... it's a development box, and if security matters,
  # something is profoundly incorrect with what you're doing.
  config.ssh.insert_key = false

  nodes.each do |node|
    @autostart = node[:autostart] ||= false

    config.vm.define node[:hostname], autostart: @autostart do |nodeconfig|
      nodeconfig.vm.box = node[:boxfile]
      nodeconfig.vbguest.installer_hooks[:before_install] = ["dnf install -y https://people.centos.org/arrfab/shim/results.c8/kernel/20190604090648/4.18.0-80.el8.x86_64/kernel-devel-4.18.0-80.el8.x86_64.rpm", "sleep 1"]

      nodeconfig.vm.hostname = node[:hostname] + ".box"

      if node[:ip]
        nodeconfig.vm.network :private_network, ip: node[:ip]
      else
        nodeconfig.vm.network :private_network, type: "dhcp"
      end

      if node[:port_map]
        node[:port_map].each do |hport, gport|
          nodeconfig.vm.network "forwarded_port", host: "#{hport}", guest: "#{gport}"
        end
      end

      cpus = 1
      memory = 1024

      if node[:cpus]
        cpus = node[:cpus]
      end

      if node[:memory]
        memory = node[:memory]
      end

      nodeconfig.vm.provider :virtualbox do |box|
        box.memory = memory
        box.cpus   = cpus
        box.customize ["modifyvm", :id, "--ioapic", "on"]              # necessary for 64 bit guests
        box.customize ["modifyvm", :id, "--natdnshostresolver1", "on"] # magic to make DNS work
      end

      if Vagrant::Util::Platform.windows? then
        nodeconfig.vm.synced_folder "./scripts", "/scripts"
        nodeconfig.vm.synced_folder "./files", "/files"
        nodeconfig.vm.synced_folder "./repo", "/repo"
      else
        nodeconfig.vm.synced_folder "./scripts", "/scripts", type: "nfs"
        nodeconfig.vm.synced_folder "./files", "/files", type: "nfs"
        nodeconfig.vm.synced_folder "./repo", "/repo", type: "nfs"
      end

      if node[:script]
        nodeconfig.vm.provision "shell" do |s|
          s.path = node[:script]
          s.args = node[:args]
        end
      end

    end # config.vm.define
  end # nodes.each
end # Vagrant.configure





