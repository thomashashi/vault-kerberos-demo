# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.network "private_network", type: "dhcp", virtualbox__intnet: true
  config.vm.box = "debian/buster64"

  config.vm.define "kdc" do |kdc|
    kdc.vm.hostname = "kdc.example.local"
    kdc.vm.provision "shell", path: "setups/kdc.setup"
  end
  
  config.vm.define "ldap" do |ldap|
    ldap.vm.hostname = "ldap.example.local"
    ldap.vm.provision "shell", path: "setups/ldap.setup"
  end
  
  config.vm.define "vault", primary: true do |vault|
    vault.vm.provider "virtualbox" do |v|
      v.customize ["setextradata", :id, "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled", "1"]
    end
    vault.vm.hostname = "vault.example.local"
    vault.vm.provision "shell", path: "setups/vault.setup"
  end


  config.vm.provision "shell", path: "setups/base.setup"
  config.vm.provision "shell", path: "setups/ssh.setup"
  config.vm.provision "shell", path: "setups/mdns.setup"

end
