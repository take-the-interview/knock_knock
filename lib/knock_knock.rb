require 'knock_knock/version'
require 'knock_knock/util'
require 'pry'

module KnockKnock
  def self.has_permission?(permission, resource, policy, roles_with_permissions)
    raise ArgumentError, "permission can't be nil" if permission.nil?
    raise ArgumentError, "resource can't be nil" if resource.nil?
    raise ArgumentError, "policy can't be nil" if policy.nil?
    raise ArgumentError, "roles_with_permissions can't be nil" if roles_with_permissions.nil?


    resource_patterns = KnockKnock::Util.extract_resource_patterns(resource)
    resource_patterns.each do |resource_pattern|
      if policy['statements'].has_key?(resource_pattern)
        statement_permissions = KnockKnock::Util.extract_permissions_from_roles(policy['statements'][resource_pattern], roles_with_permissions)
        if statement_permissions.include?(permission)
          return true
        end
      end
    end
    
    return false
  end

  def self.add_roles(policy, roles, resource)
    raise ArgumentError, "permission can't be nil" if policy.nil?
    raise ArgumentError, "roles can't be nil" if roles.nil?
    raise ArgumentError, "roles can't be empty array" if roles.empty?
    raise ArgumentError, "resource can't be nil" if resource.nil?

    if policy['statements'].has_key?(resource)
      policy['statements'][resource] += roles
    else
      policy['statements'][resource] = roles
    end

    policy
  end

  def self.remove_roles(policy, roles, resource)
    raise ArgumentError, "permission can't be nil" if policy.nil?
    raise ArgumentError, "roles can't be nil" if roles.nil?
    raise ArgumentError, "roles can't be empty array" if roles.empty?
    raise ArgumentError, "resource can't be nil" if resource.nil?

    policy['statements'][resource] -= roles

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
