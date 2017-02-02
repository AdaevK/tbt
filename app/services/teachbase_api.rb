class TeachbaseApi
  include HTTParty
  base_uri 'http://s1.teachbase.ru'

  attr_reader :access_token, :status_code

  def course_sessions options = { access_type: 'open' }
    call(:get, '/endpoint/v1/course_sessions', body: options)
  end

  private

    def call method, path, header: {}, body: {}
      params = {
        headers: header.merge({ 'Authorization' => "Bearer #{access_token}" }),
        body: body
      }

      if authorize
        response = self.class.send(method, path, params)
        @status_code = response.code

        { body: Oj.load(response.body), status_code: status_code }
      else
        { body: nil, status_code: status_code }
      end
    end

    def authorize
      response = self.class.post('/oauth/token',
        body: {
          client_id: ENV['CLIENT_KEY'],
          client_secret: ENV['CLIENT_SECRET'],
          grant_type: 'client_credentials'
      })

      @status_code = response.code
      if status_code == 200
        @access_token = Oj.load(response.body)['access_token']

        return true
      else
        return false
      end
    end
end
