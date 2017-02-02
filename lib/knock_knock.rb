require 'knock_knock/version'
require 'knock_knock/util'

module KnockKnock
  def self.has_permission?(permission, resource, policy, permission_groups_mapping)
    raise ArgumentError, "permission can't be nil" if permission.nil?
    raise ArgumentError, "resource can't be nil" if resource.nil?
    raise ArgumentError, "policy can't be nil" if policy.nil?
    raise ArgumentError, "permission_groups_mapping can't be nil" if permission_groups_mapping.nil?


    resource_patterns = KnockKnock::Util.extract_resource_patterns(resource)
    resource_patterns.each do |resource_pattern|
      if policy['statements'].has_key?(resource_pattern)
        statement_permissions = KnockKnock::Util.extract_permissions_from_permission_groups(policy['statements'][resource_pattern], permission_groups_mapping)
        if statement_permissions.include?(permission)
          return true
        end
      end
    end
    
    return false
  end

  def self.add_permission_groups(policy, permission_groups, resource)
    raise ArgumentError, "policy can't be nil" if policy.nil?
    raise ArgumentError, "permission_groups can't be nil" if permission_groups.nil?
    raise ArgumentError, "permission_groups can't be empty array" if permission_groups.empty?
    raise ArgumentError, "resource can't be nil" if resource.nil?

    if policy['statements'].has_key?(resource)
      policy['statements'][resource] += permission_groups
      policy['statements'][resource].uniq!
    else
      policy['statements'][resource] = permission_groups
    end

    policy
  end

  def self.remove_permission_groups(policy, permission_groups, resource)
    raise ArgumentError, "policy can't be nil" if policy.nil?
    raise ArgumentError, "permission_groups can't be nil" if permission_groups.nil?
    raise ArgumentError, "permission_groups can't be empty array" if permission_groups.empty?
    raise ArgumentError, "resource can't be nil" if resource.nil?

    policy['statements'][resource] -= permission_groups

    if policy['statements'][resource].empty?
      policy['statements'].delete(resource)
    end

    policy
  end

  def self.create_policy(etag, version)
    raise ArgumentError, "etag can't be nil" if etag.nil?
    raise ArgumentError, "version can't be nil" if version.nil?
    raise ArgumentError, "wrong argument type #{etag.class} (expected Integer)" unless etag.kind_of?(Integer)
    raise ArgumentError, "wrong argument type #{version.class} (expected String)" unless version.instance_of?(String)

    policy = { 'etag' => etag , 'version' => version, 'statements' => { } }
  end
end
