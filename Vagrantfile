Vagrant.configure("2") do |config|
  config.vm.box = "precise64"

  config.vm.define :controller do |controller|
    controller.vm.network :private_network, ip: "192.168.51.10"
    ## Forward the default IPython notebook port on the guest
    ## to the host
    controller.vm.network :forwarded_port, guest: 8888, host: 18888

    # Run salt master and minion on the controller node
    controller.vm.synced_folder "salt/roots/", "/srv/"
    controller.vm.provision :salt do |salt|
      #salt.install_master = true
      salt.minion_config = "salt/minion"
      salt.run_highstate = true
      salt.verbose = true
    end
  end

  config.vm.define :worker do |worker|
    worker.vm.network :private_network, ip: "192.168.51.11"
    # Only run salt minion on the worker nodes
    worker.vm.provision :salt do |salt|
      salt.install_master = false
      salt.minion_config = "salt/minion"
      salt.run_highstate = true
      salt.verbose = true
    end
  end
end
