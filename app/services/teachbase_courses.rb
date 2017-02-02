class TeachbaseCourses
  include Redis::Objects
  include Virtus.model

  attribute :id, String, default: ENV['CLIENT_KEY']
  attribute :page, Integer, default: 1
  attribute :access_type, String, default: 'open'

  value :body
  value :status
  value :updated_at
  value :server_broken

  def initialize *arg
    super
    # Сохранякм переменной из кеша, что бы после неудачного выполнения response
    # состояние response_invalid? было true, а не сразу переходило в server_broken?
    @status_server_broken = (self.server_broken == 'true')
  end

  def get
    response[:status_code]
    # Обновляем статус после запроса
    self.set_status(response[:status_code]) if response[:status_code]

    return nil if response[:status_code] == 401 or response[:body].nil?

    # Если удачный запрос первой страницы, то сохраняем обновленый список на первой страницы
    set_body(response[:body]) if page == 1 and response[:status_code] == 200

    response[:body].map{ |item| CourseItem.new item }
    # response[:body]
  end

  # Проверка на удачность запроса
  def response_invalid?
    not server_broken? and not ['200', '401'].include?(status.value)
  end

  # Проверка лежит ли сервер
  def server_broken?
    @status_server_broken
  end

  def set_body(value)
    self.body = Oj.dump(value)
    # Обновляем дату последнего удачного запроса
    self.updated_at = DateTime.now
  end

  def set_status(value)
    self.server_broken = true unless [200, 401].include?(value)
    self.status = value
  end

  def get_updated_at
    DateTime.parse(self.updated_at)
  end

  private
    def load_items value
      Oj.load(value)
    end

    def response
      @response ||= if server_broken? # Если сервер лежит сразу берем старую копию
          { body: load_items(self.body.value) }
        else
          # Выполняем запрос к серверу
          result = TeachbaseApi.new.course_sessions page: page, access_type: access_type
          # Если запрос неудачный, берем старую копию
          result[:body] = load_items(self.body.value) if result[:status_code] != 200
          result
        end
    end

end
