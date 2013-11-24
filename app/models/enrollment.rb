class Enrollment < ActiveRecord::Base
  attr_accessible :course_name, :user_id
  belongs_to :user
  belongs_to :course
end