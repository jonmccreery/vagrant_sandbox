nodes = [
  # here be the box definitions
  {
    :hostname  => 'dev-cent7',
    :ip        => '192.168.0.10',
    :boxfile   => 'centos/7',
    :script    => 'data/config.sh',
    :autostart => true,
  }
]

Vagrant.configure("2") do |config|
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

      nodeconfig.vm.synced_folder "./data", "/data"

      if node[:script]
        nodeconfig.vm.provision "shell" do |s|
          s.path = node[:script]
          s.args = node[:args]
        end
      end

    end # config.vm.define
  end # nodes.each
end # Vagrant.configure





