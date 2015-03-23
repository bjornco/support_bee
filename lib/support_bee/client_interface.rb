require 'rest-client'
require 'support_bee/configuration'
require 'support_bee/error'
require 'support_bee/response_handler'
require 'support_bee/dottable_response'

module SupportBee
  module ClientInterface
    include SupportBee::Configuration

    def ticket(id)
      get "/tickets/#{ id }" do |response|
        response.on :ok, DottableResponse.new(:ticket)
        response.on :not_found, NotFound
      end
    end

    def create_ticket(params)
      post "/tickets", params: { ticket: params } do |response|
        response.on :created, DottableResponse.new(:ticket)
        response.on :bad_request, BadRequest
      end
    end

    def archive_ticket(ticket_id)
      post "/tickets/#{ ticket_id }/archive" do |response|
        response.on :no_content, -> (_) { true }
        response.on :not_found, NotFound
      end
    end

    def add_label(ticket_id, label)
      post "/tickets/#{ ticket_id }/labels/#{ label }" do |response|
        response.on :created, DottableResponse.new(:label)
        response.on :not_found, NotFound
      end
    end


    private

    def get(endpoint, params: {}, headers: {})
      url = build_url(endpoint, params.merge(auth_token: config.auth_token))
      handler = yield ResponseHandler.new
      RestClient.get(url, build_headers(headers), &handler)
    end

    def post(endpoint, params: {}, headers: {})
      url = build_url(endpoint, auth_token: config.auth_token)
      handler = yield ResponseHandler.new
      RestClient.post(url, params, build_headers(headers), &handler)
    end

    def build_url(endpoint, params)
      uri = URI.parse(company_url)
      uri.path = endpoint
      uri.query = URI.encode_www_form(params)
      uri.to_s
    end

    def build_headers(headers={})
      { content_type: :json, accept: :json }.merge(headers)
    end

    def company_url
      @company_url ||= "https://#{config.company}.supportbee.com/".freeze
    end
  end
end
