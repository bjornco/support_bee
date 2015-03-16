module SupportBee
  module Configuration
    attr_accessor :auth_token, :company

    def configure
      yield self
    end
  end
end
