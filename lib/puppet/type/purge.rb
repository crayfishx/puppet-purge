require 'puppet'

Puppet::Type.newtype(:purge) do

  
  @doc=(<<-EOT)
  This is a metatype to purge resources from the agent.  When run without 
  parameters the purge type takes a resource type as a title.  The 
  resource type must be one that has a provider that supports the instances
  method (eg: package, user, yumrepo).  Any instances of the resource found
  on the agent that are *not* in the catalog will be purged.

  You can also add filter conditions to control the behaviour of purge 
  using the if and unless parameters.

  Eg:
  To remove *all* users found on the system that are not present in the
  catalog (caution!):
 
   purge { 'user': }

  To remove all users found on the system but not in the catalog, unless
  the user has a UID below 500:
 
   purge { 'user':
    unless => [ 'uid', '<=', '500' ],
   }
  EOT

  # By setting @isomorphic to false Puppet will allow duplicate namevars
  # (not duplicate titles).  This allows for multiple purge resource types
  # to be declared purging the same resource type with different criteria
  #
  @isomorphic = false

  newparam(:resource_type) do
    isnamevar
    desc "Name of the resource type to be purged"
    validate do |name|
      raise ArgumentError, "Unknown resource type #{name}" unless Puppet::Type.type(name)
    end
  end


  [ :unless, :if ]. each do |param_name|
    newparam(param_name, :array_matching => :all) do

      desc(<<-EOT)
      Purge resources #{param_name.to_s} they meet the criteria.
      Criteria is defined as an array of "parameter", "operator", and "value".
      
      Eg:
         #{param_name.to_s} => [ 'name', '==', 'root' ]

      Operators can support "!=","==","=~",">","<","<=",">=" as an argument
      Value can be a string, integer or regex (without the enclosing slashes)

      Multiple criterias can be nested in an array, eg:

         #{param_name.to_s} => [ 
           [ 'name', '==', 'root' ], [ 'name', '=~', 'admin.*' ]
         ]
      EOT



      validate do |cond|
        raise ArgumentError, "must be an array" unless cond.is_a?(Array)
      end
  
      munge do |cond|
        if cond[0].is_a?(Array)
          cond
        else
          [ cond ]
        end
      end
  
      validate do |cond_param|
        case cond_param[0]
        when String
          cond = [ cond_param ]
        when Array
          cond = cond_param
        end
  
        cond.each do |param, operator, value|
          unless ["!=","==","=~",">","<","<=",">="].include?(operator)
            raise ArgumentError, "invalid operator #{operator}"
          end
  
          unless param && operator && value
            raise ArgumentError, "not enough parameters given for filter"
          end
        end
      end
    end



  end

  

  def generate
    klass = Puppet::Type.type(self[:name])
    resource_instances = klass.instances

    purged_resources = []

    ## Don't try and perge things that are in the catalog
    resource_instances.reject!{ |r| catalog.resource_refs.include? r.ref }

    ## Don't purge things that have been filtered with if/unless
    resource_instances.select!{ |r| purge?(r) }

    resource_instances.each do |res|
      res[:ensure] = :absent
      purged_resources << res
    end
    purged_resources
  end

  # purge will evaluate the conditions given in if/unless
  def purge?(res_type)

    res = res_type.to_resource.to_hash

    if self[:unless]
      return false unless evaluate_resource(res, self[:unless])
    end

    if self[:if]
      return false if evaluate_resource(res, self[:if])
    end

    return true
  end

  # evaluate_resources loops through the array of param, operator, value
  # and returns true if any of the criteria match
  #
  def evaluate_resource(res,condition)
    condition.select  {  |param, operator, value|
      case operator
      when "!=", "=="
        res[param.to_sym].to_s.send(operator, value)
      when "=~"
        res[param.to_sym] =~ Regexp.new(value)
      when ">=", "<=", ">", "<"
        res[param.to_sym].to_i.send(operator, value.to_i)
      end
    }.length == 0
  end

end

