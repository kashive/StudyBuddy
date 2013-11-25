class Course < ActiveRecord::Base
  include PublicActivity::Common
  validate :cannot_have_more_than_six_courses, on: :create
  attr_accessible :name, :department, :professor, :term

  has_many :study_sessions
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments , dependent: :destroy


  def cannot_have_more_than_six_courses
  	if  Course.where("user_id='#{@attributes['user_id']}'").size() > 5
  		errors.add(:term,"You can only add upto six courses")
  	end
  end
  # this method returns all the study session for the course
  def getAllStudySessions
    StudySession.where("course_name = '#{self.name}'")
  end

  def getUpcomingStudySessions
    StudySession.where("course_name = '#{self.name}' AND time >= '#{Time.now}'")
  end
end
