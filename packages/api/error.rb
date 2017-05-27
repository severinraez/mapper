module API
  class Error
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def concat(other_error)
      message += "\n" + other_error.message
    end

    private
    attr_writer :message
  end
end
