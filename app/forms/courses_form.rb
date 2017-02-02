class CoursesForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  include Virtus.model

  attr_reader :items

  attribute :page, Integer, default: 1

  validate :invalid_authentication
  validate :response_invalid
  validate :server_broken

  def get
    @items = teachbase_courses.get
    valid?
  end

  private

    def teachbase_courses
      @teachbase_courses ||= TeachbaseCourses.new page: page
    end

    def invalid_authentication
      errors.add(:base, :invalid_auth) if teachbase_courses.invalid_authentication?
    end

    def response_invalid
      if date = teachbase_courses.get_updated_at
        errors.add(:base, :response_invalid_with_date, date: date.strftime("%d.%m.%Y %H:%M"))
      else
        errors.add(:base, :response_invalid)
      end if teachbase_courses.response_invalid?
    end

    def server_broken
      if teachbase_courses.server_broken?
        hours = ((DateTime.now.to_i - teachbase_courses.get_updated_at.to_i) /3600).round
        errors.add(:base, :server_broken, hours: hours)
      end
    end
end
