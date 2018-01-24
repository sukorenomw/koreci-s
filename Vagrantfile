# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 1.5'

def require_plugins(plugins = {})
  needs_restart = false
  plugins.each do |plugin, version|
    next if Vagrant.has_plugin?(plugin)
    cmd =
      [
        'vagrant plugin install',
        plugin
      ]
    cmd << "--plugin-version #{version}" if version
    system(cmd.join(' ')) || exit!
    needs_restart = true
  end
  exit system('vagrant', *ARGV) if needs_restart
end

require_plugins \
  'vagrant-bindfs' => '0.3.2'

def ansible_installed?
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).any? do |p|
    exts.any? do |ext|
      full_path = File.join(p, "ansible-playbook#{ext}")
      File.executable?(full_path) && File.file?(full_path)
    end
  end
end


Vagrant.configure('2') do |config|
  config.vm.provider :virtualbox do |vb, override|
    host = RbConfig::CONFIG["host_os"]

    if host =~ /darwin/ # OS X
      # sysctl returns bytes, convert to MB
      vb.memory = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 3
      vb.cpus = `sysctl -n hw.ncpu`.to_i
    elsif host =~ /linux/ # Linux
      # meminfo returns kilobytes, convert to MB
      vb.memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 2
      vb.cpus = `nproc`.to_i
    end

    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.define 'koreci-s' do |machine|
    machine.vm.hostname = 'localhost'
    machine.vm.network 'forwarded_port', :guest => 3000, :host => 3000, :auto_correct => true

    machine.vm.box = 'ubuntu/trusty64'

    machine.vm.network 'private_network', ip: '10.10.10.12'
    machine.vm.synced_folder '.', '/koreci-s', :type => 'nfs'
    machine.vm.synced_folder 'railsbox/ansible', '/ansible', :type => 'nfs'
    machine.bindfs.bind_folder '//koreci-s', '//koreci-s'
    machine.bindfs.bind_folder '/ansible', '/ansible'
  end


  config.ssh.forward_agent = true

  if ansible_installed?
    config.vm.provision 'ansible' do |ansible|
      ansible.playbook = 'railsbox/ansible/site.yml'
      ansible.sudo = true
      ansible.groups = {
        'application' => %w(koreci-s),
        'vm' => %w(koreci-s),
        'postgresql' => %w(koreci-s),
        'redis' => %w(koreci-s),
        'sidekiq' => %w(koreci-s),
        'development:children' => %w(application vm postgresql redis sidekiq),
      }
      ansible.tags = ENV['TAGS']
      ansible.raw_arguments = ENV['ANSIBLE_ARGS']
    end
  else
    Dir['railsbox/shell/*.sh'].each do |script|
      config.vm.provision 'shell', :path => script, :privileged => false, :args => ENV['ANSIBLE_ARGS']
    end
  end
end
