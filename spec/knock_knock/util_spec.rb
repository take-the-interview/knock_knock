require 'spec_helper'

describe KnockKnock::Util do
  describe '.extract_resource_patterns' do
    it 'splits resource by colons, and returns array with resource patterns' do
      resource = 'companies/1:departments/1:interviews/62'
      resource_patterns = ['companies/1', 'companies/*', 'companies/1/departments/1', 'companies/1/departments/*',
        'companies/1/departments/1/interviews/62', 'companies/1/departments/1/interviews/*']

      expect(KnockKnock::Util.extract_resource_patterns(resource)).to eq resource_patterns
    end
  end

  describe '.extract_permissions_from_permission_groups' do
    it 'returns array with permissions for given permission group' do
      permission_group1 = 'companies.departments.interviews.user_interviews.fullAccess'
      permission_group1_permissions = ['companies.departments.interviews.show', 'companies.departments.interviews.create',
        'companies.departments.interviews.edit']
      permission_groups = [permission_group1]
      permission_groups_mapping = { permission_group1 => permission_group1_permissions }
      
      expect(KnockKnock::Util.extract_permissions_from_permission_groups(permission_groups, permission_groups_mapping)).to eq permission_group1_permissions
    end
    
    it 'raises exception if there is no mapping with given role in the list' do
      role1 = 'companies.departments.interviews.user_interviews.fullAccess'
      role1_permissions = ['companies.departments.interviews.show', 'companies.departments.interviews.create',
        'companies.departments.interviews.edit']
      
      roles = ['test']
      permission_groups_mapping = { role1 => role1_permissions }
      

      expect(KnockKnock::Util.extract_permissions_from_permission_groups(roles, permission_groups_mapping)).to eq []
    end
  end
end