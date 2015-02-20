# Acquia Ruby SDK

The Acquia Ruby SDK allows developers to interact and build tools using the
Acquia platform.

## Requirements

- Ruby 2.0+

## Installation

Pop the following into your Gemfile.

```rb
gem 'acquia_sdk_ruby'
```

Or if you would like to install it yourself, try this:

```sh
$ gem install acquia_sdk_ruby
```

## Usage examples

### Cloud API

```rb
# Initiate a connection by passing in the user credentials.
client = Acquia::CloudApi::Client.new({
  username: 'my_user@example.com',
  password: 'topsecretpassword',
  site: 'devcloud:example'
})

# If you wish to leverage an existing cloudapi.conf or netrc entry, that is
# supported as well - just don't pass in the details and it will find it for
# you.
client = Acquia::CloudApi::Client.new
```

### Make a request

```rb
client = Acquia::CloudApi::Client.new

# Make a request to the 'sites.json' endpoint. This URL is relative to the
# https://cloudapi.acquia.com/v1/ path.
client.get 'sites.json'
```

## Using a proxy or firewall?

No problem! The Acquia gem includes the ability to leverage environment
variables for defining proxies or firewall rules. Just define your gateway using
the `HTTPS_PROXY` variable and it will be included for all requests.

## Contributing

- Fork this repository.
- Create a new feature branch (`git checkout -b my-awesome-feature`).
- Make your proposed changes.
- Commit them to the feature branch.
- Push up your changes and open a new pull request.

_NB: If you are making code changes, they will require tests to accompany them
otherwise your changes may accidently break in future releases._
