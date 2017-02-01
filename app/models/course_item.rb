class CourseItem
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :started_at, DateTime
  attribute :finished_at, DateTime
  attribute :course_id, Integer
  attribute :infinitely, Boolean
  attribute :access_type, String
  attribute :finished, Boolean
  attribute :navigation, Integer
  attribute :apply_url, String
  attribute :deadline_soon, Boolean
  attribute :assignments_count, Integer
  attribute :deadline_type, Integer
  attribute :slug, String

  attribute :course, Course
end
