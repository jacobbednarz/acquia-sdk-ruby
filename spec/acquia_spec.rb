require 'spec_helper'

describe '#cloud_api_endpoint' do
  it 'should return as a string' do
    expect(Acquia.cloud_api_endpoint).to be_kind_of(String)
  end

  it 'should contain the api endpoint and version' do
    expect(Acquia.cloud_api_endpoint).to include(Acquia.cloud_api_uri)
    expect(Acquia.cloud_api_endpoint).to include(Acquia.cloud_api_version)
  end
end

describe '#cloud_api_uri' do
  it 'should return as a string' do
    expect(Acquia.cloud_api_uri).to be_kind_of(String)
  end
end

describe '#cloud_api_version' do
  it 'should return as a string' do
    expect(Acquia.cloud_api_version).to be_kind_of(String)
  end
end
