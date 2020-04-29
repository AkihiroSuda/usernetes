# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
# TODO: update to Fedora 32 (https://github.com/rootless-containers/usernetes/pull/156#issuecomment-620981700)
  config.vm.box = "fedora/31-cloud-base"
  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.cpus = 2
  end
  config.vm.provider :libvirt do |v|
    v.memory = 2048
    v.cpus = 2
  end
  config.vm.provision "shell", inline: <<-SHELL
    dnf install -y iptables
  SHELL
end
