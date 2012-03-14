sudo "install rvm" do
  user "jenkins"
  command "bash -s stable < <(curl -sk https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)"
  simulate_initial_login true
end

include_recipe "jenkins::jenkins"

package "jenkins"


execute "setup-jenkins" do
  notifies :stop, resources(:service => "jenkins"), :immediately
  notifies :create, resources(:ruby_block => "netstat"), :immediately
  notifies :install, resources(:package => "jenkins"), :immediately
  creates "/usr/share/jenkins/jenkins.war"
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
  group "jenkins"
  mode  0755
  action :create
end


log "start-jenkins" do
  notifies :start, resources(:service => "jenkins"), :immediately
  notifies :create, resources(:ruby_block => "block_until_operational"), :immediately  
end

remote_file "/var/lib/jenkins/updates/default.json" do
  source "http://guardian.rumblelabs.com/jenkins-update-centre.json"
  owner "jenkins"
  group "jenkins"
  mode "0755"
end

execute "update-jenkins-plugin-data" do
  command "curl -X POST -H 'Accept: application/json' -d @/var/lib/jenkins/updates/default.json http://#{node[:fqdn]}:#{node[:jenkins][:server][:port]}/updateCenter/byId/default/postBack"
end

template "/var/lib/jenkins/.rvmrc" do
  source      "jenkins.rvmrc.erb"
  owner       'jenkins'
  group       'jenkins'
  mode        '0644'
end

template "/var/lib/jenkins/.bashrc" do
  source      "jenkins.bashrc.erb"
  owner       'jenkins'
  group       'jenkins'
  mode        '0644'
end


["git", "rake", "rubyMetrics", "ruby", "openid", "performance", "github-api", "github", "hipchat", "rvm", "gravatar"].each do |plugin|
  jenkins_cli "install-plugin #{plugin}"
end

# Jenkins update centre has the derps with invalid json that's why I think these plugins 
# can't be found ("gravatar" "rvm")  http://updates.jenkins-ci.org/update-center.json
# ["http://updates.jenkins-ci.org/download/plugins/rvm/0.2/rvm.hpi", "http://updates.jenkins-ci.org/download/plugins/gravatar/1.1/gravatar.hpi"].each do |plugin|
#   jenkins_cli "install-plugin #{plugin}"
# end

include_recipe "jenkins::plugins"

# log "plugins updated, restarting jenkins" do
#   notifies :stop, resources(:service => "jenkins"), :immediately
#   notifies :create, resources(:ruby_block => "netstat"), :immediately
#   notifies :start, resources(:service => "jenkins"), :immediately
#   notifies :create, resources(:ruby_block => "block_until_operational"), :immediately
# end


# jenkins_cli "reload-configuration"

# Front Jenkins with an HTTP server
case node[:jenkins][:http_proxy][:variant]
when "nginx"
  include_recipe "jenkins::proxy_nginx"
when "apache2"
  include_recipe "jenkins::proxy_apache2"
end

execute "setup-projects" do
  ["guardian"].each do |project|
    command "wget -qO- #{node[:jenkins][:jobs][:config_url]}/#{project}.xml | /usr/bin/java -jar /home/jenkins/jenkins-cli.jar -s http://#{node[:fqdn]}:#{node[:jenkins][:server][:port]} create-job"
    creates "/var/lib/jenkins/jobs/#{project}/config.xml"
  end
end

template "#{node[:jenkins][:server][:home]}/.ssh/config" do
  source      "jenkins.ssh.config.erb"
  owner       'jenkins'
  group       'jenkins'
  mode        '0600'
end

log "restart-jenkins" do
  notifies :restart, resources(:service => "jenkins"), :immediately
end
