class StudySession < ActiveRecord::Base
	include PublicActivity::Common
  	attr_accessible :category, :date, :description, :location, :time, :title
  	belongs_to :course

  	# returns the user that created this study session
  	def getUser
  		user_id = Course.where("id = '#{self.course_id}'").first.user_id
  		return User.where("id = '#{user_id}'")
  	end
end
