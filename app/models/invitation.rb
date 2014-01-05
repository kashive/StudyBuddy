class Invitation < ActiveRecord::Base
  attr_accessible :course_id, :host_id, :status, :study_session_id, :user_id
  has_many :notifications, as: :notifiable

  def getStudySession
  	return StudySession.where("id = '#{self.study_session_id}'").first
  end
end
