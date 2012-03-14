class Chef
  class Recipe
    # name        The name of the service.  Looks for a template named NAME.conf
    # variables   Hash of variables to pass to the template
    # reload      Reload monit so it notices the new service.  :delayed (default) or :immediately.

    def monitrc(name, variables = {}, options = {})
      options = { :reload => :delayed, :source => "#{ name }.conf.erb" }.merge(options)
      log "Making monitrc for: #{ name }"
      template "/etc/monit/conf.d/#{ name }.conf" do
        owner "root"
        group "root"
        mode 0644
        source options[:source]
        variables variables
        notifies :restart, resources(:service => "monit"), options[:reload]
        action :create
      end
    end
  end
end
