require "spec_helper"

describe KnockKnock do
  describe '.has_permission?' do
    let!(:permission) { 'companies.interviews.create' }
    let!(:resource) { 'companies/1:department/1:interviews/62' }
    let!(:policy) { { 'etag' => 123456789, 'statements' => [ { 'roles' => ['companies.interviews.fullAccess'], 'resources' => ['companies/1', 'company/2'] } ] } }
    let!(:roles_with_permissions) { { 'companies.interviews.fullAccess' => ['companies.interviews.show', 'companies.interviews.create', 'companies.interviews.edit'] } }

    it 'returns true if there is permission in policy for given resource' do
      expect(KnockKnock.has_permission?(permission, resource, policy, roles_with_permissions)).to eq true
    end

    it 'returns false if there is no permission in policy for given resource' do
      policy = { 'etag' => 123456789, 'statements' => [ { 'roles' => ['companies.interviews.readOnly'], 'resources' => ['companies/1', 'company/2'] } ] }

      expect(KnockKnock.has_permission?(permission, resource, policy, roles_with_permissions)).to eq false
    end

    it 'returns false if there is permission in policy but not for given resource' do
      policy = { 'etag' => 123456789, 'statements' => [ { 'roles' => ['companies.interviews.fullAccess'], 'resources' => ['company/2'] } ] }

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
end
