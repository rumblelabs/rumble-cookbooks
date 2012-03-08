include_recipe "apt"

template "/etc/apt/sources.list.d/canonical.com.list" do
  mode "0644"
  source "canonical.com.list.erb"
  notifies :run, resources(:execute => "apt-get update"), :immediately
end

execute "agree to Sun license" do
  command 'echo "sun-java6-bin shared/accepted-sun-dlj-v1-1 boolean true" | debconf-set-selections'
end

package "sun-java6-jre"
package "sun-java6-jdk"
package "default-jre-headless"

execute "update Java alternatives" do
  command "update-java-alternatives -s java-6-sun; echo 0"
end