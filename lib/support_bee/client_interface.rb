module SupportBee
  module ClientInterface

    def ticket(id)
      url = build_url("/tickets/#{ id }")

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
      RestClient.post(build_url("/tickets", include_auth_token: false), { ticket: params }, build_headers) do |response, request, result, &block|
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
      url = build_url("/tickets/#{ ticket_id }/labels/#{ label }")

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

    def build_url(endpoint, include_auth_token: true)
      uri = URI.parse(company_url)
      uri.path = endpoint

      if include_auth_token
        uri.query = URI.encode_www_form(auth_token: auth_token)
      end

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
