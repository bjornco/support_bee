require 'rest-client'

module SupportBee
  class Client
    attr_reader :auth_token, :base_url

    def initialize(options)
      @auth_token = options[:auth_token]
      @base_url = "https://#{options[:company]}.supportbee.com/"
    end

    def create_ticket(params)
      ::RestClient.post(build_url('tickets'), params)
    end

    def build_url(endpoint)
      @base_url + endpoint
    end
  end
end