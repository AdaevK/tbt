class CoursesForm
  include Virtus.model

  attr_reader :items, :message

  attribute :page, Integer, default: 1

  def get
    @items = teachbase_courses.get
  end

  def message
    @message ||= if @items.nil?
        I18n.t('courses_form.messages.invalid_auth')
      elsif teachbase_courses.response_invalid?
        I18n.t('courses_form.messages.response_invalid', date: teachbase_courses.get_updated_at.strftime("%d.%m.%Y %H:%M"))
      elsif teachbase_courses.server_broken?
        hours = ((DateTime.now.to_i - teachbase_courses.get_updated_at.to_i) /3600).round
        I18n.t('courses_form.messages.server_broken', hours: hours)
      else
        nil
      end
  end
  private

    def teachbase_courses
      @teachbase_courses ||= TeachbaseCourses.new page: page
    end
end
