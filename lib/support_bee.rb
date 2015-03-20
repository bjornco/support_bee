require "support_bee/version"
require "support_bee/client_interface"
require "support_bee/client"

module SupportBee
  class << self
    include SupportBee::ClientInterface
  end
end
