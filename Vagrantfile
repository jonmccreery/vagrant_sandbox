nodes = [
  # here be the box definitions
  {
    :hostname  => 'dev-cent8',
    :cpus      => 3,
    :memory    => 2048,
    :ip        => '192.168.0.10',
    :boxfile   => 'roboxes/rocky8',
    #:boxfile   => 'morlock/dev-cent8',
    #:boxfile   => 'mgv/centos-8-vbguest',
    #:boxfile   => 'centos/8',
    :script    => 'scripts/config_dev.sh',
    :autostart => true,
  },
  {
    :hostname  => 'kali',
    :boxfile   => 'offensive-security/kali-linux',
    :script    => 'scripts/config_dev.sh',
    :autostart => true,
  },
  {
    :hostname  => 'blank',
    :ip        => '192.168.0.51',
    :boxfile   => 'morlock/dev-cent8',
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





