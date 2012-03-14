
def initialize(name, run_context=nil)
  super(name, run_context)
  @resource_name = :sudo
  @action = "execute"
  @allowed_actions.push(:execute)
end

def command(arg=nil)
  set_or_return(
    :command,
    arg,
    :kind_of => [ String ]
  )
end

def user(arg=nil)
  set_or_return(
    :user,
    arg,
    :kind_of => [ String ]
  )
end

def group(arg=nil)
  set_or_return(
    :group,
    arg,
    :kind_of => [ String ]
  )
end

def simulate_initial_login(arg=nil)
  set_or_return(
    :simulate_initial_login,
    arg,
    :kind_of => [ TrueClass, FalseClass ]
  )
end

def cwd(arg=nil)
  set_or_return(
    :cwd,
    arg,
    :kind_of => [ String ]
  )
end

def environment(arg=nil)
  set_or_return(
    :environment,
    arg,
    :kind_of => [ Hash ]
  )
end
