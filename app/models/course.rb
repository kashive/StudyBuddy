class Course < ActiveRecord::Base
  attr_accessible :name, :number, :professor, :term
end
