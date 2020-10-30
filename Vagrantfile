Vagrant.configure("2") do |config|
	config.vm.define :vma1 do |vma1|
		vma1.vm.box = "bento/ubuntu-20.04"
		vma1.vm.hostname = "vma1"
		vma1.vm.network :private_network, ip: "192.168.100.131"
		vma1.vm.provision "shell", path: "script_provision_vma1.sh"
		vma1.vm.synced_folder "carpeta_sincronizada", "/home/vagrant/carpeta_sincronizada"
		vma1.vm.provider "virtualbox" do |v|
			v.name = "vma1"
			v.memory = 1024
			v.cpus =1
		end
	end

	config.vm.define :vma2 do |vma2|
		vma2.vm.box = "bento/ubuntu-20.04"
		vma2.vm.hostname = "vma2"
		vma2.vm.network :private_network, ip: "192.168.100.132"
		vma2.vm.provision "shell", path: "script_provision_vma2.sh"
		vma2.vm.synced_folder "carpeta_sincronizada", "/home/vagrant/carpeta_sincronizada"
		vma2.vm.provider "virtualbox" do |v|
			v.name = "vma2"
			v.memory = 1024
			v.cpus =1
		end
	end

	config.vm.define :vma3 do |vma3|
		vma3.vm.box = "bento/ubuntu-20.04"
		vma3.vm.hostname = "vma3"
		vma3.vm.network :private_network, ip: "192.168.100.133"
		vma3.vm.provision "shell", path: "script_provision_vma3.sh"
		vma3.vm.synced_folder "carpeta_sincronizada", "/home/vagrant/carpeta_sincronizada"
		vma3.vm.provider "virtualbox" do |v|
			v.name = "vma3"
			v.memory = 1024
			v.cpus =1
		end
	end
end