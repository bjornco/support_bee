require 'rest-client'
require 'hashie'

module SupportBee
  class Client
    attr_reader :auth_token, :base_url

    def initialize(options)
      @auth_token = options[:auth_token]
      @base_url = "https://#{options[:company]}.supportbee.com/"
    end

    def create_ticket(params)
      resp = RestClient.post(build_url('tickets'), { ticket: params }, { content_type: :json, accept: :json })
      parse_json(resp).ticket
    end

    private

    def build_url(endpoint)
      @base_url + endpoint
    end

    def parse_json(json)
      Hashie::Mash.new(JSON.parse(json))
    end

  end
end