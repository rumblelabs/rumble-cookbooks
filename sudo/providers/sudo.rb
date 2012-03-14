def load_current_resource
end

def action_execute
  command = ["sudo"]
  command << "-u #{@new_resource.user}" if @new_resource.user
  command << "-g #{@new_resource.group}" if @new_resource.group
  command << "-i" if @new_resource.simulate_initial_login
  
  # changed " to ' to support `command`
  if @new_resource.cwd
    command << %Q{ bash -c 'cd #{@new_resource.cwd} && #{@new_resource.command}'}
  else
    command << %Q{ bash -c '#{@new_resource.command}'}
  end

  options = {:command => command.join(' ')}
  options[:environment] = @new_resource.environment if @new_resource.environment

  Chef::Mixin::Command.run_command(options)
  Chef::Log.info "Ran sudo [#{@new_resource.name}]"
end