class StudySession < ActiveRecord::Base
  	attr_accessible :category, :date, :description, :location, :time, :title
  	belongs_to :course
end
