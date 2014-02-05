class Notification < ActiveRecord::Base

  attr_accessible :action, :host_id, :notifiable_type, :notifiable_id, :user_id, :seen
  belongs_to :notifiable, polymorphic: true
  after_create :sendPushNotification, if: -> {self.action.split('_').first != "session"}
  
  def sendPushNotification
    debugger
    require 'eventmachine'
    toShow = Notification.showableNotification([self])
    EM.run {
      client = Faye::Client.new('http://0.0.0.0:9292/faye')
      publication= client.publish("/foo/#{self.user_id}", toShow)
      publication.callback do
        logger.debug "Message received by server! Data #{toShow}"
      end

      publication.errback do |error|
        logger.debug 'There was a problem: ' + error.message
      end
    }
  end

  def self.showableNotification(notificationArray)
    toShow = {}
    notificationArray.each do |notification|
      hostUser = User.where("id = '#{notification.host_id}'").first
      if notification.action == "user_join"
        course = notification.notifiable
        if course == nil
          pathAndTime = []
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} has joined a course of yours which has since been deleted"
        else
          receivingUser = User.where("id = '#{notification.user_id}'").first
          courseForReceiver = Course.where("user_id = '#{notification.user_id}' AND name ='#{course.name}'").first
          pathAndTime = []
          pathAndTime.push(Rails.application.routes.url_helpers.user_course_path(receivingUser.id,courseForReceiver.id))
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} has joined #{course.name} and is now a classmate"
        end
        toShow[notificationText] = pathAndTime
      elsif notification.action == "invited"
        invitation = notification.notifiable
        if invitation == nil || invitation.getStudySession == nil
          pathAndTime=[]
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} has invited you to for a study session which has since been deleted"
        else
          studySession = StudySession.where("id = '#{invitation.study_session_id}'").first
          course = Course.where("id = '#{invitation.course_id}'").first
          pathAndTime=[]
          pathAndTime.push(Rails.application.routes.url_helpers.user_course_study_session_path(hostUser,course.id, studySession.id))
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} has invited you to join #{studySession.title} for your #{course.name} class"
        end
        toShow[notificationText] = pathAndTime
      elsif notification.action == "rsvp_yes"
        studySession = notification.notifiable
        if studySession == nil
          pathAndTime = []
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} was attending a study session which has since been deleted"
        else
          pathAndTime = []
          pathAndTime.push(Rails.application.routes.url_helpers.user_course_study_session_path(hostUser,studySession.getCourse.id, studySession.id))
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} is attending #{studySession.title}"
        end
        toShow[notificationText] = pathAndTime
      elsif notification.action == "session_delete"
        course = notification.notifiable
        if course == nil
          pathAndTime = []
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "A course and study session that you rsvp'ed for is removed"
        else
          pathAndTime = []
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "A study session for #{course.name} that you rsvp'ed has been cancelled"
        end
        toShow[notificationText] = pathAndTime
      elsif notification.action == "session_update"
        studySession = notification.notifiable
        if studySession == nil
          pathAndTime = []
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} edited a study session you rsvp'ed for, which has since been deleted"
        else
          pathAndTime = []
          pathAndTime.push(Rails.application.routes.url_helpers.user_course_study_session_path(hostUser,studySession.getCourse.id, studySession.id))
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} updated study session #{studySession.title} which you are attending"
        end
        toShow[notificationText] = pathAndTime
      elsif notification.action == "session_2_hour_update" || notification.action == "session_24_hour_update"
        studySession = notification.notifiable
        if studySession == nil
          pathAndTime = []
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          message = ""
          if notification.action == "session_2_hour_update"
            message = "The study session by #{hostUser.first_name} was happening in 2 hours but now is cancelled."
          else
            message = "The study session by #{hostUser.first_name} was happening in 24 hours but now is cancelled."
          end
          notificationText = message
        else
          pathAndTime = []
          pathAndTime.push(Rails.application.routes.url_helpers.user_course_study_session_path(hostUser,studySession.getCourse.id, studySession.id))
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          if notification.action == "session_2_hour_update"
            message = "Reminder: #{studySession.title} is happening in 2 hours at #{studySession.location}"
          else
            message = "Reminder: #{studySession.title} is happening in 24 hours at #{studySession.location}"
          end
          notificationText = message
        end
        toShow[notificationText] = pathAndTime
      end
    end
    return toShow
  end

end


