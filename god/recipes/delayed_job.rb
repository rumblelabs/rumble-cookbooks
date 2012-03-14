node[:deploy].each do |application, deploy|
  next unless node[:delayed_job][:applications].include?(application)
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
    notifies :restart, resources(:service => "god")
  end
end