node[:deploy].each do |application, deploy|
  next unless node[:delayed_job][:applications].include?(application)

  execute "update app" do
    command "cd #{deploy[:deploy_to]}/current && RAILS_ENV=#{deploy[:rails_env]} bundle install"
  end

  execute "add env vars" do
    command "ln -s #{deploy[:deploy_to]}/shared/.env #{deploy[:deploy_to]}/current/.env"
  end

end
