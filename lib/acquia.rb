require 'acquia/version'
require 'acquia/cloudapi'
require 'acquia/exceptions'

module Acquia
  # Internal: The Cloud API endpoint as a full URI.
  #
  # Returns a string of the endpoint.
  def self.cloud_api_endpoint
    "#{cloud_api_uri}/#{cloud_api_version}/"
  end

  # Internal: The base URI of the Acquia Cloud API.
  #
  #  Returns a string of the base URI.
  def self.cloud_api_uri
    'https://cloudapi.acquia.com'
  end

  # Internal: Current version of the Cloud API.
  #
  # Returns a string which indicates the current version of the Cloud API.
  def self.cloud_api_version
    'v1'
  end
end
