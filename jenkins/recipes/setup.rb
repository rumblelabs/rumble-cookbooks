pkey = "#{node[:jenkins][:server][:home]}/.ssh/id_rsa"
tmp = "/tmp"

user node[:jenkins][:server][:user] do
  home node[:jenkins][:server][:home]
end

directory node[:jenkins][:server][:home] do
  recursive true
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
end

directory "#{node[:jenkins][:server][:home]}/.ssh" do
  mode 0700
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
end

execute "ssh-keygen -f #{pkey} -N ''" do
  user  node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  not_if { File.exists?(pkey) }
end

ruby_block "store jenkins ssh pubkey" do
  block do
    node.set[:jenkins][:server][:pubkey] = File.open("#{pkey}.pub") { |f| f.gets }
  end
end

template "#{node[:jenkins][:server][:home]}/.ssh/config" do
  source      "jenkins.ssh.config.erb"
  owner       'jenkins'
  group       'jenkins'
  mode        '0600'
end

directory "#{node[:jenkins][:server][:home]}/plugins" do
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  # only_if { node[:jenkins][:server][:plugins].size > 0 }
end


include_recipe "apt"
package "openjdk-6-dbg"
package "openjdk-6-jre"
package "openjdk-6-jdk"
package "openjdk-6-jre-lib"
package "openjdk-6-jre-headless"
execute "jenkins-key" do
  command "wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -"
end

# RAILS TEST DEPENDENCIES
package "libxml2-dev"
package "libxslt1-dev"
package "libmagickwand-dev"
package "nodejs"
package "autoconf"
include_recipe "mysql::server"
