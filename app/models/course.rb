class Course < ActiveRecord::Base
  attr_accessible :name, :number, :professor, :term
  has_many :enrollments
  has_many :users, through: :enrollments
end
