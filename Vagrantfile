# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
hosts = YAML.load_file(File.join(File.dirname(__FILE__), 'hosts.yml'))

Vagrant.configure("2") do |config|
  config.vagrant.plugins = [
    'vagrant-hosts',
    'vagrant-hostmanager',
    'vagrant-auto_network',
    'vagrant-vbguest'
  ]
  hosts.each_with_index do |(host, host_configs), index|
    config.vm.define host do |client|
      config.vm.box = "bento/debian-9.9"
      config.vm.box_version = "201907.07.0"
      config.vm.provider "virtualbox" do |v|
        v.memory = 4096
        v.cpus = 2
      end
      config.vbguest.auto_update = false
      config.vbguest.no_remote = true
      if host_configs.include? "ip"
        client.vm.network :private_network, ip: host_configs['ip']
      else
        client.vm.network :private_network, :auto_network => true
      end
      if host_configs.include? "aliases"
        client.hostmanager.aliases = host_configs["aliases"]
      end
      # Disbable syncing default vagrant folder for faster provisioning
      client.vm.synced_folder ".", "/vagrant", disabled: true
      client.vm.provision :hosts, :sync_hosts => true
      client.vm.provision :shell, :path => 'provisioning/provision.sh'
      client.vm.provision :hostmanager
      if host_configs.include? "folders"
        host_configs["folders"].each do |folder|
          client.vm.synced_folder folder["map"], folder["to"]
        end
      end
    end
  end

end
