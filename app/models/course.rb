class Course < ActiveRecord::Base
  attr_accessible :name, :department, :professor, :term
  has_many :enrollments
  has_many :study_sessions
  has_many :users, through: :enrollments
end
