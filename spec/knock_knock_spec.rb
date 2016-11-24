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

    it 'raises exception if policy is nil' do
      expect { KnockKnock.add_roles(nil, [role1], resource) }.to raise_error(ArgumentError)
    end

    it 'raises exception if roles is nil' do
      expect { KnockKnock.add_roles(policy, nil, resource) }.to raise_error(ArgumentError)
    end

    it 'raises exception if roles is nil' do
      expect { KnockKnock.add_roles(policy, [], resource) }.to raise_error(ArgumentError)
    end

    it 'raises exception if resource is nil' do
      expect { KnockKnock.add_roles(policy, [role1], nil) }.to raise_error(ArgumentError)
    end
  end

  describe '.remove_roles' do
    let!(:role1) { 'companies.interviews.user_interviews.manageResponses' }
    let!(:role2) { 'companies.interviews.fullAccess' }
    let!(:resource) { 'companies/1' }
    let!(:policy) { { 'etag' => 123456789, 'version' => 1, 'statements' => { resource => [role1, role2] } } }
    

    it 'removes roles from resource' do
      updated_policy = KnockKnock.remove_roles(policy, [role1], resource)

      expect(updated_policy['statements'][resource]).to eq [role2]
    end

    it 'removes resource if it does not contain any role' do
      updated_policy = KnockKnock.remove_roles(policy, [role1, role2], resource)

      expect(updated_policy['statements']).not_to have_key(resource)
    end

    it 'raises exception if policy is nil' do
      expect { KnockKnock.remove_roles(nil, [role1], resource) }.to raise_error(ArgumentError)
    end

    it 'raises exception if roles is nil' do
      expect { KnockKnock.remove_roles(policy, nil, resource) }.to raise_error(ArgumentError)
    end

    it 'raises exception if roles is nil' do
      expect { KnockKnock.remove_roles(policy, [], resource) }.to raise_error(ArgumentError)
    end

    it 'raises exception if resource is nil' do
      expect { KnockKnock.remove_roles(policy, [role1], nil) }.to raise_error(ArgumentError)
    end
  end

  describe '.create_policy' do
    etag = 123
    version = '1'

    it 'returns policy structure with required fields' do
      policy = KnockKnock.create_policy(etag, version)

      expect(policy.keys.sort).to eq ['etag', 'version', 'statements'].sort
      expect(policy['etag']).to eq etag
      expect(policy['version']).to eq version
      expect(policy['statements']).to eq({})
    end

    it 'raises exception if etag is nil' do
      expect { KnockKnock.create_policy(nil, version) }.to raise_error(ArgumentError, "etag can't be nil")
    end

    it 'raises exception if version is nil' do
      expect { KnockKnock.create_policy(etag, nil) }.to raise_error(ArgumentError, "version can't be nil")
    end
    
    it 'raises exception if etag is not integer' do
      etag = 123.45

      expect { KnockKnock.create_policy(etag, version) }.to raise_error(ArgumentError, "wrong argument type #{etag.class} (expected Integer)")
    end

    it 'raises exception if version is not string' do
      version = 1
      
      expect { KnockKnock.create_policy(etag, version) }.to raise_error(ArgumentError, "wrong argument type #{version.class} (expected String)")
    end
  end
end
