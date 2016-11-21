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

  describe '.extract_permissions_from_roles' do
    it 'returns array with permissions for given roles' do
      role1 = 'companies.departments.interviews.user_interviews.fullAccess'
      role1_permissions = ['companies.departments.interviews.show', 'companies.departments.interviews.create',
        'companies.departments.interviews.edit']
      roles = [role1]
      roles_with_permissions = { role1 => role1_permissions }
      
      expect(KnockKnock::Util.extract_permissions_from_roles(roles, roles_with_permissions)).to eq role1_permissions
    end
    
    it 'raises exception if there is no mapping with given role in the list' do
      role1 = 'companies.departments.interviews.user_interviews.fullAccess'
      role1_permissions = ['companies.departments.interviews.show', 'companies.departments.interviews.create',
        'companies.departments.interviews.edit']
      
      roles = ['test']
      roles_with_permissions = { role1 => role1_permissions }
      

      expect(KnockKnock::Util.extract_permissions_from_roles(roles, roles_with_permissions)).to eq []
    end
  end
end