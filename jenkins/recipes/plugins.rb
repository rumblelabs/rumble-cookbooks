host_name = node[:jenkins][:http_proxy][:host_name]

template "#{node[:jenkins][:server][:home]}/jenkins.plugins.hipchat.HipChatNotifier.xml" do
  source      "jenkins.hipchat.config.erb"
  owner       'jenkins'
  group       'jenkins'
  mode        '0644'
  variables(
    :host_name        => host_name,
    :hipchat_token    => node[:jenkins][:hipchat][:token],
    :hipchat_room     => node[:jenkins][:hipchat][:room]
  )
end

template "#{node[:jenkins][:server][:home]}/hudson.plugins.git.GitSCM.xml" do
  source      "jenkins.git.config.erb"
  owner       'jenkins'
  group       'jenkins'
  mode        '0644'
  variables(
    :git_name        => node[:jenkins][:git][:name],
    :git_email       => node[:jenkins][:git][:email]
  )
end