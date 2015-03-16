require "support_bee/version"
require "support_bee/error"
require "support_bee/configuration"
require "support_bee/client_interface"
require "support_bee/client"

module SupportBee
  class << self
    include SupportBee::Configuration
    include SupportBee::ClientInterface
  end
end
