class Invitation < ActiveRecord::Base
  attr_accessible :course_id, :host_id, :status, :study_session_id, :user_id
  has_many :notifications, as: :notifiable
  after_save :send_email_notification

  def getStudySession
  	return StudySession.where("id = '#{self.study_session_id}'").first
  end

  def send_email_notification
  	study_session = self.getStudySession
  	study_session.getInvited.each do |invited_user|
        StudySessionMailer.study_session_invite(study_session,invited_user).deliver
    end
  end
end
