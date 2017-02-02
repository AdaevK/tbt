module Teachbase
  class AuthorizeError < StandardError
    attr_reader :body, :status_code

    def initialize body, status_code
      @body = body
      @status_code = status_code
    end
  end
end
