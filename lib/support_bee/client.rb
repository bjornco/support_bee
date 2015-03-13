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
      resp = RestClient.post(build_url('tickets'), { ticket: params }, build_headers)
      parse_json(resp).ticket
    end

    def add_label(ticket_id, label)
      url = build_url("tickets/#{ ticket_id }/labels/#{ label }?auth_token=#{ auth_token }")
      resp = RestClient.post(url, {}, build_headers)
      parse_json(resp).label
    end

    private

    def build_url(endpoint)
      @base_url + endpoint
    end

    def parse_json(json)
      Hashie::Mash.new(JSON.parse(json))
    end

    def build_headers(headers={})
      { content_type: :json, accept: :json }.merge(headers)
    end

  end
end