module Acquia
  class MissingCloudApiCredentials < StandardError; end
  class MissingNetrcConfiguration < StandardError; end

  # Generic response error.
  class ApiRequestError < StandardError; end
end
