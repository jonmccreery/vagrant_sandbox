nodes = [
  # here be the box definitions
  {
    :hostname  => 'dev-cent7',
    :cpus      => 3,
    :memory    => 2048,
    :ip        => '192.168.0.10',
    :boxfile   => 'centos/7',
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
    :hostname  => 'ip_scan',
    :ip        => '192.168.0.53',
    :script    => 'scripts/config_ipscan.sh',
    :boxfile   => 'centos/7',
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

      nodeconfig.vm.network :private_network, ip: node[:ip]

      if node[:port_map]
        node[:port_map].each do |hport, gport|
          nodeconfig.vm.network "forwarded_port", host: "#{hport}", guest: "#{gport}"
        end
      end

      memory = 1024
      cpus   = 1

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





