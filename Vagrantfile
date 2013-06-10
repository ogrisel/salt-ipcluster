Vagrant.configure("2") do |config|
  ## Choose your base box
  config.vm.box = "precise64"

  ## For masterless, mount your file roots file root
  config.vm.synced_folder "salt/roots/", "/srv/"

  ## Forward the default IPython notebook port on the guest
  ## to the host
  config.vm.network :forwarded_port, guest: 8888, host: 8888

  ## Set your salt configs here
  config.vm.provision :salt do |salt|

    ## Minion config is set to ``file_client: local`` for masterless
    salt.minion_config = "salt/minion"

    ## Installs our example formula in "salt/roots/salt"
    salt.run_highstate = true

    ## Display salt highstate output
    salt.verbose = true

  end
end
