class StudySession < ActiveRecord::Base
	include PublicActivity::Common
  	attr_accessible :category, :date, :description, :location, :time, :title, :host_id
  	belongs_to :course
    has_many :notifications, as: :notifiable

  	# returns the user that created this study session
  	def getUser
  		user_id = Course.where("id = '#{self.course_id}'").first.user_id
  		return User.where("id = '#{user_id}'")
  	end

  	def getCourse
  		return Course.where("id='#{self.course_id}'").first
  	end

    def getYes
      rsvpYes = []
      Invitation.where("study_session_id = '#{self.id}' AND status = 'yes'").each do |invitation|
        rsvpYes.push(User.where("id = '#{invitation.user_id}'").first)
      end
      return rsvpYes
    end

    def getNo
      rsvpNo = []
      Invitation.where("study_session_id = '#{self.id}' AND status = 'no'").each do |invitation|
        rsvpNo.push(User.where("id = '#{invitation.user_id}'").first)
      end
      return rsvpNo
    end

    def getInvited
      rsvpInvited = []
      Invitation.where("study_session_id = '#{self.id}' AND status = 'invited'").each do |invitation|
        rsvpInvited.push(User.where("id = '#{invitation.user_id}'").first)
      end
      return rsvpInvited
    end
end
