# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

# Check required plugins
REQUIRED_PLUGINS_LIBVIRT = %w(vagrant-libvirt)
exit unless REQUIRED_PLUGINS_LIBVIRT.all? do |plugin|
  Vagrant.has_plugin?(plugin) || (
    puts "The #{plugin} plugin is required. Please install it with:"
    puts "$ vagrant plugin install #{plugin}"
    false
  )
end

Vagrant.configure("2") do |config|

  # node1 VM
  config.vm.define "docker1" do |node|
    node.vm.hostname = "node-docker-01"
    node.vm.box = "debian/jessie64"
    node.vm.box_check_update = false
    node.vm.synced_folder '.', '/vagrant', :disabled => true
    node.vm.network "private_network", ip: "192.168.122.10"
    node.vm.provider :libvirt do |domain|
      domain.memory = 512
      domain.nested = true
    end
  end
  # node1 VM
  config.vm.define "docker2" do |node|
    node.vm.hostname = "node-docker-02"
    node.vm.box = "debian/jessie64"
    node.vm.box_check_update = false
    node.vm.synced_folder '.', '/vagrant', :disabled => true
    node.vm.network "private_network", ip: "192.168.122.11"
    node.vm.provider :libvirt do |domain|
      domain.memory = 512
      domain.nested = true
    end
  end
end
