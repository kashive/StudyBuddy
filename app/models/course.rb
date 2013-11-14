class Course < ActiveRecord::Base
  attr_accessible :name, :department, :professor, :term
  has_many :enrollments, foreign_key: :course_name, dependent: :destroy
  has_many :users, through: :enrollments , dependent: :destroy
end
