class GetDataFromTeachbaseJob < ApplicationJob
  queue_as :default

  def perform(*args)
    TeachbaseCourses.new.get
  end
end
