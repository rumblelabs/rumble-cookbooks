node[:deploy].each do |application, deploy|
  cron "delayed job cron for #{application}" do
    action  :create
    minute  "*/#{node[:delayed_job][:cron_interval]}"
    hour    '*'
    day     '*'
    month   '*'
    weekday '*'
    command "cd #{deploy[:deploy_to]}/current && RAILS_ENV=#{deploy[:rails_env]} bundle exec rake jobs:work --queue#{node[:delayed_job][:queue]}" 
    user deploy[:user]
    path "/usr/bin:/usr/local/bin:/bin"
  end
end
