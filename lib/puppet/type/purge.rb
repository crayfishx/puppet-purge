require 'puppet'

Puppet::Type.newtype(:purge) do

  @doc = "Purge all the things"

  newparam(:name) do
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

      Operators can support "!=","==","=~",">","<","<=","=>" as an argument
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
          unless ["!=","==","=~",">","<","<=","=>"].include?(operator)
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
    resource_instances = Puppet::Type.type(self[:name]).instances
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
        res[param.to_sym].to_s.method(operator).(value)
      when "=~"
        res[param.to_sym] =~ Regexp.new(value)
      when ">=", "<=", ">", "<"
        res[param.to_sym].to_i.method(operator).(value.to_i)
      end
    }.length == 0
  end

end

