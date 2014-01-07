class StudySession < ActiveRecord::Base
	include PublicActivity::Common
  	attr_accessible :category, :description, :location, :time, :title, :host_id, :twoHourReminder, :twentyFourHourReminder
    validates :title, :time, :category, :location, :description, presence: true
    validate :old_date?
  	belongs_to :course
    before_destroy :deleteAllInvitations
    has_many :notifications, as: :notifiable

    def old_date?
      if self.time == nil
        self.errors.add(:time, 'Please select time')
        return false 
      end
      if self.time < Time.now
        self.errors.add(:time, 'Please select time in the future') 
        return false
      else
        return true
      end
    end

    def deleteAllInvitations
      Invitation.where("study_session_id = '#{self.id}'").each do |invitation| invitation.destroy end
    end
  	# returns the user that created this study session
  	def getUser
  		user_id = Course.where("id = '#{self.course_id}'").first.user_id
  		return User.where("id = '#{user_id}'")
  	end

    def sendReminder(timeBeforeEvent)
      action = ""
      if timeBeforeEvent == 20
        action = "session_2_hour_update"
      else
        action = "session_24_hour_update"
      end
        allInvitedAndHost = self.getYes.push(self.getUser)
        allInvitedAndHost.each do |rsvpYesUser|
          notification = self.notifications.create("host_id"=>current_user.id,
                                                             "user_id"=>rsvpYesUser.id,
                                                             "action"=> action,
                                                             "seen"=>false )
            notificationArray = []
            notificationArray.push(notification)
            toShow = showableNotification(notificationArray)
            sendPushNotification("/foo/#{rsvpYesUser.id}", toShow)
        end
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

    def getRsvpStatus(user_id)
      yesPeople = self.getYes
      noPeople = self.getNo
      invitedPeople = self.getInvited
      allStatusPeople = []
      allStatusPeople.push(yesPeople,noPeople,invitedPeople)
      allStatusPeople.each do |people|
        people.each do |rsvpedUser|
          if rsvpedUser.id = user_id.to_i
            return Invitation.where("study_session_id = '#{self.id}' AND user_id = '#{rsvpedUser.id}'").first.status
          end
        end
      end
      return "none"
    end

    def getNo
      rsvpNo = []
      Invitation.where("study_session_id = '#{self.id}' AND status = 'no'").each do |invitation|
        rsvpNo.push(User.where("id = '#{invitation.user_id}'").first)
      end
      return rsvpNo
    end

    # this does not include yes or no
    def getInvited
      rsvpInvited = []
      Invitation.where("study_session_id = '#{self.id}' AND status = 'invited'").each do |invitation|
        rsvpInvited.push(User.where("id = '#{invitation.user_id}'").first)
      end
      return rsvpInvited
    end

    def isInvited?(user_id)
      self.getInvited.each do |invitedUser|
        if invitedUser.id == user_id
          return true
        else
          return false
        end
      end
    end
end
