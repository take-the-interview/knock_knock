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

    policy['statements'].each do |statement|
      statement_permissions = KnockKnock::Util.extract_permissions_from_roles(statement['roles'], roles_with_permissions)

      if statement_permissions.include?(permission)
        return true if (resource_patterns & statement['resources']).any?
      end
    end

    return false
  end
end
