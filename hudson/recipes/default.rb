package "openjdk-6-dbg"
package "openjdk-6-jre"
package "openjdk-6-jdk"
package "openjdk-6-jre-lib"
package "openjdk-6-jre-headless"
package "maven2"
package "daemon"
package "tomcat6"
package "tomcat6-common"

execute "delete default tomcat doc root" do
  command "rm -rf /var/lib/tomcat6/webapps/ROOT*"
end

remote_file "/var/lib/tomcat6/webapps/ROOT.war" do
  source "http://hudson-ci.org/latest/hudson.war"
  mode "0664"
end

template "/etc/tomcat6/policy.d/04webapps.policy" do
  source "04webapps.policy.erb"
end

template "/etc/default/tomcat6" do
  source "tomcat-defaults.erb"
  mode "0644"
  owner "root"
  group "root"
end

template "/etc/tomcat6/server.xml" do
  source "server.xml.erb"
  mode "0644"
  owner "root"
  group "root"
end

template "/etc/tomcat6/context.xml" do
  source "context.xml.erb"
end

execute "ensure correct permissions" do
  command "chmod  -R u+rwx /var/lib/tomcat6/webapps/"
end

service "tomcat6" do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :restart]
end