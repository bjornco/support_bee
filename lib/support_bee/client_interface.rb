module SupportBee
  module ClientInterface

    def ticket(id)
      get "/tickets/#{ id }" do |response, request, result, &block|
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
      post "/tickets", params: { ticket: params } do |response, request, result, &block|
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
      post "/tickets/#{ ticket_id }/labels/#{ label }" do |response, request, result, &block|
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

    def get(endpoint, params: {}, headers: {}, &block)
      params[:auth_token] = auth_token
      url = build_url(endpoint, params)
      RestClient.get(url, build_headers(headers), &block)
    end

    def post(endpoint, params: {}, headers: {}, &block)
      url = build_url(endpoint, auth_token: auth_token)
      RestClient.post(url, params, build_headers(headers), &block)
    end

    def build_url(endpoint, params)
      uri = URI.parse(company_url)
      uri.path = endpoint
      uri.query = URI.encode_www_form(params)
      uri.to_s
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

    def company_url
      @company_url ||= "https://#{company}.supportbee.com/".freeze
    end
  end
end
