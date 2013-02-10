node[:deploy].each do |application, deploy|
  next unless node[:delayed_job][:applications].include?(application)

  execute "start god" do
    command "sudo god -c /etc/god/master.god"
    not_if do
      `ps xU root | grep god` =~ /ruby/
    end
  end

  execute "update app" do
    command "cd #{deploy[:deploy_to]}/current && RAILS_ENV=#{deploy[:rails_env]} bundle install"
  end

  execute "add env vars" do
    command "ln -s #{deploy[:deploy_to]}/shared/.env #{deploy[:deploy_to]}/current/.env"
  end

  execute "restart delayed job" do
    command "god restart delayed_job_production"
  end

  service "nginx" do
    # supports :status => true, :restart => true, :reload => true
    action :stop
  end

end
