default[:delayed_job] = {}
default[:delayed_job][:cron_interval] = 10
default[:delayed_job][:queue] = "default"
default[:delayed_job][:command] = "bundle exec rake jobs:work"