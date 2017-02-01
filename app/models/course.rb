class Course
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :created_at, DateTime
  attribute :updated_at, DateTime
  attribute :owner_id, Integer
  attribute :owner_name, String
  attribute :thumb_url, String
  attribute :cover_url, String
  attribute :description, String
  attribute :last_activity, DateTime
  attribute :total_score, Integer
  attribute :total_tasks, Integer
  attribute :is_netology, Boolean
  attribute :bg_url, String
  attribute :video_url, String
  attribute :demo, Boolean
end
