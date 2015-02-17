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

        @client = build_client(options)

        response = client.get 'sites.json'
        fail InvalidUserCredentials, 'Invalid user credentials' if response.status == 401

        # Haven't made a site selection? Looks like you get the first one we
        # find.
        options[:site] ||= JSON.parse(response.body).first
      end

      def build_client(options = {})
        # Build our client using a proxy and correct SSL options.
        Faraday.new(url: Acquia.cloud_api_endpoint, ssl: ssl_opts) do |c|
          c.adapter Faraday.default_adapter
          c.headers['User-Agent'] = "Acquia SDK (#{Acquia::VERSION})"
          c.basic_auth(options[:username], options[:password])
          c.proxy proxy_opts
        end
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
    end
  end
end
