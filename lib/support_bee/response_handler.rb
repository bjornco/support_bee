module SupportBee
  class ResponseHandler
    STATUS_CODES = {
      ok:           200,
      created:      201,
      no_content:   204,
      bad_request:  400,
      not_found:    404
    }.freeze

    def to_proc
      -> (response, *_) { trigger(response.code, response.body) }
    end

    def initialize
      @callbacks = {}
    end

    def on(status, callback)
      @callbacks.store(STATUS_CODES[status.to_sym], callback)
      self
    end

    def trigger(code, response_body)
      if callback = @callbacks[code.to_i]
        callback.to_proc.call(response_body)
      else
        raise UnhandledResponse.new("Handler was triggered with status code `#{code}` but no callback was registered for status code `#{code}`.")
      end
    end
  end
end
