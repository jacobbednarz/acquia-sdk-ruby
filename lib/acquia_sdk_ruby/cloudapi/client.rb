require 'netrc'
require 'faraday'
require 'json'

module Acquia
  module CloudApi
    class Client
      attr_accessor :client

      def initialize(options = {})
        # Providing that we have both the username and the password, use it
        # otherwise we will run through the available authentication sources to
        # find our user details.
        options[:username] ||= user_credentials[:username]
        options[:password] ||= user_credentials[:password]

        @options = options
      end

      # Text representation of the client, masking sensitive information.
      #
      # Returns a string.
      def inspect
        inspected = super

        # Mask the password.
        if @options[:password]
          inspected = inspected.gsub! @options[:password], conceal(@options[:password])
        end

        inspected
      end

      # Internal: Get the default site for the user.
      #
      # Returns a string containing the users first site.
      def default_site
        response = get 'sites.json'
        response.first
      end

      # Public: Make a GET HTTP request.
      #
      # url - The URL to request.
      #
      # Returns a Faraday::Connection object.
      def get(url)
        request :get, url
      end

      # Internal: Conceal parts of the string.
      #
      # Example:
      #
      #   conceal "thisismysensitivestring"
      #   # => "this****ring"
      #
      # Returns a string with only the first and last 4 characters visible.
      def conceal(string)
        front = string[0, 4]
        back  = string[-4, 4]
        "#{front}****#{back}"
      end

      # Internal: Determine if the user is behind a firewall or proxy.
      #
      # Returns a boolean based on whether the environment variable is found.
      def proxy?
        (ENV['HTTPS_PROXY'].nil?) ? false : true
      end

      # Internal: Define the proxy options for requests.
      #
      # Returns hash of proxy options or nil if not in use.
      def proxy_opts
        (proxy?) ? { uri: ENV['HTTPS_PROXY'] } : nil
      end

      # Internal: Build the SSL options for requests.
      #
      # Returns a hash of the SSL options to apply to requests.
      def ssl_opts
        { verify: true, ca_file: File.expand_path('etc/ca.pem') }
      end

      # Internal: Get the user credentials from available sources.
      #
      # This method is responsible for checking the available sources and
      # providing the user credentials back in a hash.
      #
      # Returns a hash of the user credentials keyed with 'username' and
      # 'password'.
      def user_credentials
        acquia_conf_auth if File.exist? acquia_conf_path
        netrc_auth if File.exist? netrc_path
      end

      # Internal: Pull the details out of the Acquia configuration file.
      #
      # This will find the Acquia Cloud configuration file and extract the
      # username and password from the JSON object.
      #
      # Returns a hash of the username and password.
      def acquia_conf_auth
        user_data = JSON.parse(File.read(acquia_conf_path))
        { username: user_data['email'], password: user_data['key'] }
      end

      # Internal: Fetch the user credentials from a netrc file.
      #
      # Check and see if the user has a local netrc entry for the Cloud API and
      # should it be found, use it.
      #
      # Returns a hash of the username and password.
      def netrc_auth
        n = Netrc.read

        # While netrc file may exist, we cannot always be certain that the Cloud
        # API credentials are present.
        if n['cloudapi.acquia.com'].nil?
          fail MissingNetrcConfiguration, "No entry for cloudapi.acquia.com found in #{netrc_path}"
        end

        username = n['cloudapi.acquia.com'].login
        password = n['cloudapi.acquia.com'].password

        { username: username, password: password }
      end

      # Internal: Path to the Acquia Cloud configuration file.
      #
      # Returns a string of the file path to the cloudapi.conf file.
      def acquia_conf_path
        "#{Dir.home}/.acquia/cloudapi.conf"
      end

      # Internal: Path to the user's netrc.
      #
      # Returns a string of the file path to the users netrc file.
      def netrc_path
        "#{Dir.home}/.netrc"
      end

      private

      # Private: Make a HTTP request.
      #
      # url     - The relative URL of the resource to request.
      # options - Hash of options to pass through to the request.
      #
      # Returns a JSON string of the body.
      def request(method, url, options = {})
        request = Faraday.new(url: Acquia.cloud_api_endpoint, ssl: ssl_opts) do |c|
          c.adapter Faraday.default_adapter
          c.headers['User-Agent'] = "Acquia SDK (#{Acquia::VERSION})"
          c.basic_auth(@options[:username], @options[:password])
          c.proxy proxy_opts
          c.use Faraday::Response::RaiseError
        end

        case method
        when :get
          response = request.get url
        end

        JSON.parse(response.body)
      end
    end
  end
end
