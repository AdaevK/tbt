module Teachbase
  class Api
    include HTTParty
    base_uri 'http://s1.teachbase.ru'
    open_timeout ENV.fetch("TEACHBASE_API_TIMEOUT", 10)

    class << self
      def course_sessions options = { access_type: 'open' }
        call(:get, '/endpoint/v1/course_sessions', body: options)
      end

    private

      def call method, path, header: {}, body: {}
        begin
          params = {
            headers: header.merge({ 'Authorization' => "Bearer #{access_token}" }),
            body: body
          }

          response = self.send(method, path, params)
          status_code = response.code

          { body: Oj.load(response.body), status_code: status_code }
        rescue Teachbase::AuthorizeError => e
          { body: nil, status_code: e.status_code }
        rescue Net::ReadTimeout
          { body: nil, status_code: 503 }
        end
      end

      def access_token
        response = self.post('/oauth/token',
          body: {
            client_id: ENV['CLIENT_KEY'],
            client_secret: ENV['CLIENT_SECRET'],
            grant_type: 'client_credentials'
        })

        raise Teachbase::AuthorizeError.new(response.body, response.code) unless response.code == 200

        Oj.load(response.body)['access_token']
      end
    end
  end
end
