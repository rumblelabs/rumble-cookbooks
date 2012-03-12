node[:deploy].each do |application, deploy|
  cron "delayed job cron for #{application}" do
    action  :create
    minute  "*/#{node[:delayed_job][:cron_interval]}"
    hour    '*'
    day     '*'
    month   '*'
    weekday '*'
    command "cd #{deploy[:deploy_to]}/current && RAILS_ENV=#{deploy[:rails_env]} QUEUES=#{node[:delayed_job][:queue]} bundle exec rake jobs:work" 
    user deploy[:user]
    path "/usr/bin:/usr/local/bin:/bin"
  end
end
