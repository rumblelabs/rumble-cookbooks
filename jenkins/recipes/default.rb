install_starts_service = true
include_recipe "jenkins::jenkins"

#this is defined after http_request/remote_file because the package
#providers will throw an exception if `source' doesn't exist
package "jenkins" #do
  #provider package_provider
  #source local if node.platform != "ubuntu"
  #action :nothing
#end

if node.platform == "ubuntu"
  execute "setup-jenkins" do
    command "echo w00t"
    # notifies :stop, "service[jenkins]", :immediately
    notifies :stop, resources(:service => "jenkins"), :immediately
    # notifies :create, "ruby_block[netstat]", :immediately #wait a moment for the port to be released
    notifies :create, resources(:ruby_block => "netstat"), :immediately
    # notifies :install, "package[jenkins]", :immediately
    notifies :install, resources(:package => "jenkins"), :immediately

    # command "cd /usr/share/jenkins && wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war && mv jenkins.war.1 jenkins.war"

    unless install_starts_service
      #notifies :start, "service[jenkins]", :immediately
      # notifies :start, resources(:service => "jenkins"), :immediately
    end
    #notifies :create, "ruby_block[block_until_operational]", :immediately
    #notifies :create, resources(:ruby_block => "block_until_operational"), :immediately
    creates "/usr/share/jenkins/jenkins.war"
  end
end

execute "update-jenkins" do
  command "cd /usr/share/jenkins && wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war && mv jenkins.war.1 jenkins.war"
end


template "/etc/init/jenkins.conf" do
  source      "jenkins.conf.erb"
  owner       'root'
  group       'root'
  mode        '0644'
  variables(
    :jenkins_home     => node[:jenkins][:server][:home],
    :java_home        => node[:jenkins][:java_home]
  )
end


template "/var/lib/jenkins/hudson.model.UpdateCenter.xml" do
  source      "jenkins.update_centre.erb"
  owner       'jenkins'
  group       'jenkins'
  mode        '0644'
  variables(
    :update_centre     => node[:jenkins][:update_centre]
  )
end

directory "/var/lib/jenkins/updates" do
  owner "jenkins"
  group "nogroup"
  mode  0644
  action :create
end


log "start-jenkins" do
  notifies :start, resources(:service => "jenkins"), :immediately
  notifies :create, resources(:ruby_block => "block_until_operational"), :immediately  
end

remote_file "/var/lib/jenkins/updates/default.json" do
  source "http://guardian.rumblelabs.com/jenkins-update-centre.json"
  mode "0644"
end

execute "update-jenkins-plugin-data" do
  command "curl -X POST -H 'Accept: application/json' -d @/var/lib/jenkins/updates/default.json http://#{node[:fqdn]}:#{node[:jenkins][:server][:port]}/updateCenter/byId/default/postBack"
end


# jenkins_cli "reload-configuration"


  #http_request "HEAD #{remote}" do
  #  only_if { node[:jenkins][:server][:use_head] } #XXX remove when CHEF-1848 is merged
  #  message ""
  #  url remote
  #  action :head
  #  if File.exists?(local)
  #    headers "If-Modified-Since" => File.mtime(local).httpdate
  #  end
  #  # notifies :create, "remote_file[#{local}]", :immediately
  #  notifies :create, resources(:remote_file => local), :immediately
  #end
#end

["git", "rake", "rubyMetrics", "ruby", "openid", "performance", "github-api", "github", "hipchat", "rvm", "gravatar"].each do |plugin|
  jenkins_cli "install-plugin #{plugin}"
end

# Jenkins update centre has the derps with invalid json that's why I think these plugins 
# can't be found ("gravatar" "rvm")  http://updates.jenkins-ci.org/update-center.json
# ["http://updates.jenkins-ci.org/download/plugins/rvm/0.2/rvm.hpi", "http://updates.jenkins-ci.org/download/plugins/gravatar/1.1/gravatar.hpi"].each do |plugin|
#   jenkins_cli "install-plugin #{plugin}"
# end

include_recipe "jenkins::plugins"

# restart if this run only added new plugins
log "plugins updated, restarting jenkins" do
  #ugh :restart does not work, need to sleep after stop.
  #notifies :stop, "service[jenkins]", :immediately
  notifies :stop, resources(:service => "jenkins"), :immediately
  #notifies :create, "ruby_block[netstat]", :immediately
  notifies :create, resources(:ruby_block => "netstat"), :immediately
  #notifies :start, "service[jenkins]", :immediately
  notifies :start, resources(:service => "jenkins"), :immediately
  #notifies :create, "ruby_block[block_until_operational]", :immediately
  notifies :create, resources(:ruby_block => "block_until_operational"), :immediately
  #only_if do
  #  if File.exists?(pid_file)
  #    htime = File.mtime(pid_file)
  #    Dir["#{node[:jenkins][:server][:home]}/plugins/*.hpi"].select { |file|
  #      File.mtime(file) > htime
  #    }.size > 0
  #  end
  #end
end


jenkins_cli "reload-configuration"

# Front Jenkins with an HTTP server
case node[:jenkins][:http_proxy][:variant]
when "nginx"
  include_recipe "jenkins::proxy_nginx"
when "apache2"
  include_recipe "jenkins::proxy_apache2"
end

# execute "setup-projects" do
#   ["guardian"].each do |project|
#     command "wget -qO- #{node[:jenkins][:jobs][:config_url]}/#{project}.xml | /usr/bin/java -jar /home/jenkins/jenkins-cli.jar -s http://#{node[:fqdn]}:#{node[:jenkins][:server][:port]} create-job"
#     creates "/var/lib/jenkins/jobs/#{project}/config.xml"
#   end
# end

template "#{node[:jenkins][:server][:home]}/.ssh/config" do
  source      "jenkins.ssh.config.erb"
  owner       'jenkins'
  group       'jenkins'
  mode        '0600'
end
