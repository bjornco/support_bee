require 'hashie'

module SupportBee
  class DottableResponse
    def initialize(attribute)
      @attribute = attribute
    end

    def to_proc
      -> (body) { make_dottable(parse_json body).send(@attribute) }
    end

    def make_dottable(hash)
      Hashie::Mash.new(hash)
    end

    def parse_json(json)
      JSON.parse(json)
    end
  end
end
