require 'puppet'

Puppet::Type.newtype(:purge) do

  @doc = "Purge all the things"

  newparam(:name) do
    desc "Name of the resource type to be purged"
    validate do |name|
      raise ArgumentError, "Unknown resource type #{name}" unless Puppet::Type.type(name)
    end
  end

  newparam(:if, :array_matching => :all) do
  end

  newparam(:unless, :array_matching => :all) do

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

  def evaluate_resource(res,condition)
    condition.select  {  |operator, param, value|
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

