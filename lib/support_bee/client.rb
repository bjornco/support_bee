require 'rest-client'
require 'hashie'

module SupportBee
  class Client
    attr_reader :auth_token, :base_url

    def initialize(options)
      @auth_token = options[:auth_token]
      @base_url = "https://#{options[:company]}.supportbee.com/"
    end

    def ticket(id)
      url = build_url("tickets/#{ id }?auth_token=#{ auth_token }")

      RestClient.get(url) do |response, request, result, &block|
        case response.code
        when 200
          format_response(parse_json(response)).ticket
        when 404
          raise SupportBee::NotFound.new(response.body)
        else
          response.return!(request, result, &block)
        end
      end
    end

    def create_ticket(params)
      RestClient.post(build_url('tickets'), { ticket: params }, build_headers) do |response, request, result, &block|
        case response.code
        when 201
          format_response(parse_json(response)).ticket
        when 400
          raise SupportBee::BadRequest.new(response.body)
        else
          response.return!(request, result, &block)
        end
      end
    end

    def add_label(ticket_id, label)
      url = build_url("tickets/#{ ticket_id }/labels/#{ label }?auth_token=#{ auth_token }")

      RestClient.post(url, {}, build_headers) do |response, request, result, &block|
        case response.code
        when 201
          format_response(parse_json(response)).label
        when 404
          raise SupportBee::NotFound.new(response.body)
        else
          response.return!(request, result, &block)
        end
      end
    end

    private

    def build_url(endpoint)
      @base_url + endpoint
    end

    def format_response(parsed_json)
      Hashie::Mash.new(parsed_json)
    end

    def parse_json(json)
      JSON.parse(json)
    end

    def build_headers(headers={})
      { content_type: :json, accept: :json }.merge(headers)
    end

  end
end