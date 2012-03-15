# RAILS DEPENDENCIES
package "libxml2-dev"
package "libxslt1-dev"
package "libmagickwand-dev"
package "nodejs"
package "autoconf"

directory "/srv/repos" do
  owner "deploy"
  group "www-data"
  mode  0755
  action :create
end

# runit_service "god"

node[:deploy].each do |application, deploy|
  next unless node[:delayed_job][:applications].include?(application)
  
  directory "#{deploy[:deploy_to]}/shared/log" do
    owner "deploy"
    group "www-data"
    mode  0777
    action :create
  end

  file "#{deploy[:deploy_to]}/shared/log/delayed_job.log" do
    owner "deploy"
    group "www-data"
    mode  0666
    action :create
    not_if do
      File.exists?("#{deploy[:deploy_to]}/shared/log/delayed_job.log")
    end
  end
  

  file "#{deploy[:deploy_to]}/shared/log/#{deploy[:rails_env]}.log" do
    owner "deploy"
    group "www-data"
    mode  0666
    action :create
    not_if do
      File.exists?("#{deploy[:deploy_to]}/shared/log/#{deploy[:rails_env]}.log")
    end
  end


  template "/etc/god/conf.d/delayed_job.god" do
    source "delayed_job.god.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
      :deploy_to => deploy[:deploy_to],
      :rails_env => deploy[:rails_env],
      :queue => node[:delayed_job][:queue]
    )
    #notifies :restart, resources(:service => "god")
  end

  execute "stop god" do
    command "killall -9 god"
  end

  execute "start god" do
    command "god -c /etc/god/master.god"
  end

end