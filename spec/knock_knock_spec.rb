require "spec_helper"

describe KnockKnock do
  describe '.has_permission?' do
    let!(:permission) { 'companies.interviews.create' }
    let!(:resource) { 'companies/1:department/1:interviews/62' }
    let!(:policy) { { 'etag' => 123456789, 'version' => 1, 'statements' => {
      'companies/1' => ['companies.interviews.fullAccess'], 'companies/2' => ['companies.interviews.fullAccess'] } } }
    let!(:permission_groups_mapping) { { 'companies.interviews.fullAccess' => ['companies.interviews.show',
      'companies.interviews.create', 'companies.interviews.edit'] } }

    it 'returns true if there is permission in policy for given resource' do
      expect(KnockKnock.has_permission?(permission, resource, policy, permission_groups_mapping)).to eq true
    end

    it 'returns false if there is no permission in policy for given resource' do
      policy = { 'etag' => 123456789, 'version' => 1,  'statements' => { 'companies/1' => ['companies.interviews.readOnly'], 'company/2' => ['companies.interviews.readOnly'] } }

      expect(KnockKnock.has_permission?(permission, resource, policy, permission_groups_mapping)).to eq false
    end

    it 'returns false if there is permission in policy but not for given resource' do
      policy = { 'etag' => 123456789, 'version' => 1, 'statements' => { 'company/2' => ['companies.interviews.fullAccess'] }  }

      expect(KnockKnock.has_permission?(permission, resource, policy, permission_groups_mapping)).to eq false
    end

    it 'raises exception if permission is nil' do
      expect { KnockKnock.has_permission?(nil, resource, policy, permission_groups_mapping) }.to raise_error(ArgumentError, "permission can't be nil")
    end

    it 'raises exception if resource is nil' do
      expect { KnockKnock.has_permission?(permission, nil, policy, permission_groups_mapping) }.to raise_error(ArgumentError, "resource can't be nil")
    end
    
    it 'raises exception if policy is nil' do
      expect { KnockKnock.has_permission?(permission, resource, nil, permission_groups_mapping) }.to raise_error(ArgumentError, "policy can't be nil")
    end

    it 'raises exception if permission_groups_mapping is nil' do
      expect { KnockKnock.has_permission?(permission, resource, policy, nil) }.to raise_error(ArgumentError, "permission_groups_mapping can't be nil")
    end 
  end

  describe '.add_permission_groups' do
    let!(:permission_group1) { 'companies.interviews.fullAccess' }
    let!(:resource1) { 'companies/2'}
    let!(:policy) { { 'etag' => 123456789, 'version' => 1, 'statements' => { resource1 => [permission_group1] } } }
    let!(:permission_group2) { 'companies.interviews.user_interviews.manageResponses' }
    let!(:permission_groups) { [permission_group2] }
    let!(:resource) { 'companies/7' }
    
    it 'adds new statement if there is no one with given resource' do
      updated_policy = KnockKnock.add_permission_groups(policy, permission_groups, resource)

      expect(updated_policy['statements']).to have_key(resource)
    end

    it 'adds permission_groups to existing statement if there is one with given resource' do
      resource = 'companies/2'
      updated_policy = KnockKnock.add_permission_groups(policy, permission_groups, resource)

      expect(updated_policy['statements'][resource]).to include(permission_group1)
    end

    it 'does not add duplicate entry if permission_group already exists' do
      updated_policy = KnockKnock.add_permission_groups(policy, [permission_group1], resource1)

      permission_group_counts = Hash.new(0)
      updated_policy['statements'][resource1].each { |permission_group| permission_group_counts[permission_group] += 1 }

      expect(permission_group_counts[permission_group1]).to eq 1
    end

    it 'raises exception if policy is nil' do
      expect { KnockKnock.add_permission_groups(nil, [permission_group1], resource) }.to raise_error(ArgumentError, "policy can't be nil")
    end

    it 'raises exception if permission_groups is nil' do
      expect { KnockKnock.add_permission_groups(policy, nil, resource) }.to raise_error(ArgumentError, "permission_groups can't be nil")
    end

    it 'raises exception if permission_groups is nil' do
      expect { KnockKnock.add_permission_groups(policy, [], resource) }.to raise_error(ArgumentError, "permission_groups can't be empty array")
    end

    it 'raises exception if resource is nil' do
      expect { KnockKnock.add_permission_groups(policy, [permission_group1], nil) }.to raise_error(ArgumentError, "resource can't be nil")
    end
  end

  describe '.remove_permission_groups' do
    let!(:permission_group1) { 'companies.interviews.user_interviews.manageResponses' }
    let!(:role2) { 'companies.interviews.fullAccess' }
    let!(:resource) { 'companies/1' }
    let!(:policy) { { 'etag' => 123456789, 'version' => 1, 'statements' => { resource => [permission_group1, role2] } } }
    

    it 'removes permission_groups from resource' do
      updated_policy = KnockKnock.remove_permission_groups(policy, [permission_group1], resource)

      expect(updated_policy['statements'][resource]).to eq [role2]
    end

    it 'removes resource if it does not contain any role' do
      updated_policy = KnockKnock.remove_permission_groups(policy, [permission_group1, role2], resource)

      expect(updated_policy['statements']).not_to have_key(resource)
    end

    it 'raises exception if policy is nil' do
      expect { KnockKnock.remove_permission_groups(nil, [permission_group1], resource) }.to raise_error(ArgumentError, "policy can't be nil")
    end

    it 'raises exception if permission_groups is nil' do
      expect { KnockKnock.remove_permission_groups(policy, nil, resource) }.to raise_error(ArgumentError, "permission_groups can't be nil")
    end

    it 'raises exception if permission_groups is empty array' do
      expect { KnockKnock.remove_permission_groups(policy, [], resource) }.to raise_error(ArgumentError, "permission_groups can't be empty array")
    end

    it 'raises exception if resource is nil' do
      expect { KnockKnock.remove_permission_groups(policy, [permission_group1], nil) }.to raise_error(ArgumentError, "resource can't be nil")
    end
  end

  describe '.create_policy' do
    let!(:etag) { 123 }
    let!(:version) { '1' }

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
