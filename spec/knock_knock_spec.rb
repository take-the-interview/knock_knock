require "spec_helper"

describe KnockKnock do
  describe '.has_permission?' do
    let!(:permission) { 'companies.interviews.create' }
    let!(:resource) { 'companies/1:department/1:interviews/62' }
    let!(:policy) { { 'etag' => 123456789, 'version' => 1, 'statements' => {
      'companies/1' => ['companies.interviews.fullAccess'], 'companies/2' => ['companies.interviews.fullAccess'] } } }
    let!(:roles_with_permissions) { { 'companies.interviews.fullAccess' => ['companies.interviews.show',
      'companies.interviews.create', 'companies.interviews.edit'] } }

    it 'returns true if there is permission in policy for given resource' do
      expect(KnockKnock.has_permission?(permission, resource, policy, roles_with_permissions)).to eq true
    end

    it 'returns false if there is no permission in policy for given resource' do
      policy = { 'etag' => 123456789, 'version' => 1,  'statements' => { 'companies/1' => ['companies.interviews.readOnly'], 'company/2' => ['companies.interviews.readOnly'] } }

      expect(KnockKnock.has_permission?(permission, resource, policy, roles_with_permissions)).to eq false
    end

    it 'returns false if there is permission in policy but not for given resource' do
      policy = { 'etag' => 123456789, 'version' => 1, 'statements' => { 'company/2' => ['companies.interviews.fullAccess'] }  }

      expect(KnockKnock.has_permission?(permission, resource, policy, roles_with_permissions)).to eq false
    end

    it 'raises exception if permission is nil' do
      expect { KnockKnock.has_permission?(nil, resource, policy, roles_with_permissions) }.to raise_error(ArgumentError)
    end

    it 'raises exception if resource is nil' do
      expect { KnockKnock.has_permission?(permission, nil, policy, roles_with_permissions) }.to raise_error(ArgumentError)
    end
    
    it 'raises exception if policy is nil' do
      expect { KnockKnock.has_permission?(permission, resource, nil, roles_with_permissions) }.to raise_error(ArgumentError)
    end

    it 'raises exception if roles_with_permissions is nil' do
      expect { KnockKnock.has_permission?(permission, resource, policy, nil) }.to raise_error(ArgumentError)
    end 
  end

  describe '.add_roles' do
    let!(:policy) { { 'etag' => 123456789, 'version' => 1, 'statements' => { 'companies/2' => ['companies.interviews.fullAccess'] } } }
    let!(:role1) { 'companies.interviews.user_interviews.manageResponses' }
    let!(:roles) { [role1] }
    let!(:resource) { 'companies/7' }
    
    it 'adds new statement if there is no one with given resource' do
      updated_policy = KnockKnock.add_roles(policy, roles, resource)

      expect(updated_policy['statements']).to have_key(resource)
    end

    it 'adds roles to existing statement if there is one with given resource' do
      resource = 'companies/2'
      updated_policy = KnockKnock.add_roles(policy, roles, resource)

      expect(updated_policy['statements'][resource]).to include(role1)
    end
  end
end
