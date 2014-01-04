class Course < ActiveRecord::Base
  include PublicActivity::Common
  validates :name, :department, presence: true
  validate :cannot_have_more_than_six_courses, on: :create
  attr_accessible :name, :department, :professor, :term, :course_number

  has_many :study_sessions
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments , dependent: :destroy
  has_many :notifications, as: :notifiable

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

  def getClassmates
    allEnrollments = Enrollment.where("course_name='#{self.name}'")
    classmates = []
    allEnrollments.each do |enrollment|
      classmates.push(User.where("id='#{enrollment.user_id}'").first)
    end
    return classmates;
  end

  def getTimingRecommendation
    dayTimeAndPopularity = Hash.new { |hash, key| hash[key] = {} }
    classmates = self.getClassmates
    classmates.each do |classmate|
      Schedule.where("user_id = '#{classmate.id}' AND course_id IS NULL").each do |schedule|
        time = schedule.start_time + "-" + schedule.end_time
        dayTimeAndPopularity[schedule.day][time] = dayTimeAndPopularity[schedule.day][time].to_i + 1
      end
    end
    dayTopChoice = {}
    dayTimeAndPopularity.keys.each do |day|
      dayTopChoice[day] = dayTimeAndPopularity[day].sort_by{|key,value| value}.reverse.first
    end
    return dayTopChoice
  end
end