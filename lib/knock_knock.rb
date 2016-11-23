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
    if policy['statements'].has_key?(resource)
      policy['statements'][resource] += roles
    else
      policy['statements'][resource] = roles
    end

    policy
  end

  def self.remove_roles(policy, roles, resource)
    policy['statements'][resource] -= roles

    if policy['statements'][resource].empty?
      policy['statements'].delete(resource)
    end

    policy
  end
end
