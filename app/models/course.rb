class Course < ActiveRecord::Base
  attr_accessible :name, :number, :professor, :term
  belongs_to :user
end
