class KnockKnock::Util
  def self.extract_resource_patterns(resource)
    resource_patterns = []
    previous_resource_pattern = nil

    resource.split(":").each do |resource_pattern|
      if previous_resource_pattern.nil?
        resource_pattern_without_asterisk = resource_pattern
        resource_pattern_with_asterisk = "#{resource_pattern.split('/').first}/*"
      else
        resource_pattern_without_asterisk = previous_resource_pattern + '/' + resource_pattern
        resource_pattern_with_asterisk = previous_resource_pattern + '/' + "#{resource_pattern.split('/').first}/*"
      end

      resource_patterns << resource_pattern_without_asterisk
      resource_patterns << resource_pattern_with_asterisk
      previous_resource_pattern = resource_pattern_without_asterisk
    end
    
    resource_patterns
  end

  def self.extract_permissions_from_permission_groups(permission_groups, permission_groups_mapping)
    permissions = []

    permission_groups.each do |permission_group|
      permissions << permission_groups_mapping[permission_group]
    end

    permissions.flatten!
    permissions.compact!
    permissions
  end
end