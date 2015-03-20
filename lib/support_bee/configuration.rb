module SupportBee
  module Configuration
    Config = Struct.new(:auth_token, :company)

    def configure
      yield config
    end


    private

    def config
      @config ||= Config.new
    end
  end
end
