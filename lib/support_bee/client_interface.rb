require 'rest-client'
require 'support_bee/configuration'
require 'support_bee/error'
require 'support_bee/response_handler'
require 'support_bee/dottable_response'

module SupportBee
  module ClientInterface
    include SupportBee::Configuration

    def ticket(id)
      handler = ResponseHandler.create do
        on :ok, DottableResponse.new(:ticket)
        on :not_found, NotFound
      end

      get "/tickets/#{ id }", &handler
    end

    def create_ticket(params)
      handler = ResponseHandler.create do
        on :created, DottableResponse.new(:ticket)
        on :bad_request, BadRequest
      end

      post "/tickets", params: { ticket: params }, &handler
    end

    def archive_ticket(ticket_id)
      handler = ResponseHandler.create do
        on :no_content, -> (_) { true }
        on :not_found, NotFound
      end

      post "/tickets/#{ ticket_id }/archive", &handler
    end

    def add_label(ticket_id, label)
      handler = ResponseHandler.create do
        on :created, DottableResponse.new(:label)
        on :not_found, NotFound
      end

      post "/tickets/#{ ticket_id }/labels/#{ label }", &handler
    end


    private

    def get(endpoint, params: {}, headers: {}, &block)
      params[:auth_token] = config.auth_token
      url = build_url(endpoint, params)
      RestClient.get(url, build_headers(headers), &block)
    end

    def post(endpoint, params: {}, headers: {}, &block)
      url = build_url(endpoint, auth_token: config.auth_token)
      RestClient.post(url, params, build_headers(headers), &block)
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
