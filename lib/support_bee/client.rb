require 'rest-client'
require 'hashie'

module SupportBee
  class Client
    include SupportBee::Configuration
    include SupportBee::ClientInterface

    def initialize(options)
      configure do |config|
        config.company = options[:company]
        config.auth_token = options[:auth_token]
      end
    end
  end
end