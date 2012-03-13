#
# Cookbook Name:: jenkins
# Based on hudson
# Recipe:: default
#
# Author:: Doug MacEachern <dougm@vmware.com>
# Author:: Fletcher Nichol <fnichol@nichol.ca>
#
# Copyright 2010, VMware, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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

directory "#{node[:jenkins][:server][:home]}/plugins" do
  owner node[:jenkins][:server][:user]
  group node[:jenkins][:server][:group]
  # only_if { node[:jenkins][:server][:plugins].size > 0 }
end

# node[:jenkins][:server][:plugins].each do |name|
#   remote_file "#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi" do
#     source "#{node[:jenkins][:mirror]}/latest/#{name}.hpi"
#     backup false
#     owner node[:jenkins][:server][:user]
#     group node[:jenkins][:server][:group]
#     action :nothing
#   end
# 
#   http_request "HEAD #{node[:jenkins][:mirror]}/latest/#{name}.hpi" do
#     message ""
#     url "#{node[:jenkins][:mirror]}/latest/#{name}.hpi"
#     action :head
#     if File.exists?("#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi")
#       headers "If-Modified-Since" => File.mtime("#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi").httpdate
#     end
#     notifies :create, resources(:remote_file => "#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi"), :immediately
#   end
# end

# case node.platform
# when "ubuntu"
  include_recipe "apt"
  # include_recipe "java"
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

  #apt_repository "jenkins" do
  #  uri "http://pkg.jenkins-ci.org/debian"
  #  key "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key"
  #  components ["binary/"]
  #  action :add
  #end
#end