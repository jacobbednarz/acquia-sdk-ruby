module Acquia
  class MissingCloudApiCredentials < StandardError; end
  class MissingNetrcConfiguration < StandardError; end
  class InvalidUserCredentials < StandardError; end
  class ApiRequestError < StandardError; end
end
