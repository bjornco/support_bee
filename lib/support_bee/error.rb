module SupportBee
  class Error < StandardError
    def self.to_proc
      -> (message) { raise new(message) }
    end
  end

  class UnhandledResponse < Error; end
  class BadRequest < Error; end
  class NotFound < Error; end
end
