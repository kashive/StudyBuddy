class StudySessionsController < ApplicationController

	def index
    @all_study_sessions = []
    @all_user_courses = Course.where("user_id = '#{current_user.id}'")
    @all_user_courses.each do |course|
      StudySession.where("course_name = '#{course.name}'").each do |study_session|
		    @all_study_sessions.push(study_session)
      end
    end
	end

  def destroy
    @study_session = StudySession.find(params[:id])
    course = @study_session.getCourse
    @study_session.getYes.each do |rsvpYesUser|
      next if rsvpYesUser.id == current_user.id
      notification = course.notifications.create("host_id"=>current_user.id,
                                                       "user_id"=>rsvpYesUser.id,
                                                       "action"=> "session_delete",
                                                       "seen"=>false )
      notificationArray = []
      notificationArray.push(notification)
      toShow = showableNotification(notificationArray)
      sendPushNotification("/foo/#{rsvpYesUser.id}", toShow)
    end
    Invitation.where("study_session_id = '#{@study_session.id}'").each do |invitation| invitation.destroy end
    @study_session.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path(current_user), notice: 'Study Session was successfully deleted' }
      format.json { head :no_content }
    end
  end
  
  def show
    @study_session = StudySession.find(params[:id])
    @course = @study_session.getCourse
  end

	def new
  	@studysession  = StudySession.new
    locationsArray = []
    StudySession.all.each do |ss| locationsArray.push(ss.location) end
    gon.locations = locationsArray.uniq.join(',')
	end

  def updateInvitation
    invitation = Invitation.where("user_id = '#{params[:user_id]}' AND course_id = '#{params[:course_id]}' AND study_session_id = '#{params[:id]}'").first
    study_session = StudySession.where("id = '#{params[:id]}'").first
    if invitation == nil
      invitation = Invitation.create("user_id"=>params[:user_id],
                                     "course_id"=> params[:course_id],
                                     "study_session_id"=>params[:id],
                                     "status"=>"invited",
                                     "host_id"=>study_session.host_id)
    end
    if params[:status] == "yes"
      invitation.status = "yes"
      study_session.create_activity :rsvp, owner: current_user
      notification = study_session.notifications.create("host_id"=>current_user.id,
                                                       "user_id"=>study_session.host_id,
                                                       "action"=>"rsvp_yes",
                                                       "seen"=>false
                                                       )
      notificationArray = []
      notificationArray.push(notification)
      toShow = showableNotification(notificationArray)
      sendPushNotification("/foo/#{study_session.host_id}", toShow)
    end
    invitation.status = "no" if params[:status] == "no"
    invitation.save
    redirect_to user_course_study_session_path(current_user,params[:course_id],params[:id]), notice: 'RSVP updated!'
  end

	def create
  	@studysession  = StudySession.new(:title => params[:title], :description => params[:description], :location => params[:location], :category => params[:category], :host_id => current_user.id)
    @studysession.time = DateTime.parse(Time.strptime(params[:time], '%m/%d/%Y %H:%M:%S %P').to_s)
  	@studysession.course_id = params[:course_id]
    course = Course.find(params[:course_id])
    @studysession.course_name = course.name 
		if @studysession.save
      @studysession.create_activity :create, owner: current_user
      course.getClassmates.each do |classmate|
        next if classmate.id == current_user.id
        invitation = Invitation.create("host_id"=>current_user.id,
                          "user_id"=>classmate.id,
                          "course_id"=>course.id,
                          "study_session_id"=>@studysession.id,
                          "status"=>"invited")

        notification = invitation.notifications.create("host_id"=>current_user.id,
                                                       "user_id"=>classmate.id,
                                                       "action"=> "invited",
                                                       "seen"=>false )
        notificationArray = []
        notificationArray.push(notification)
        toShow = showableNotification(notificationArray)
        sendPushNotification("/foo/#{classmate.id}", toShow)
      end
  		redirect_to user_course_study_session_path(current_user,params[:course_id],@studysession.id ), notice: 'Study Session was successfully created. Invitations sent to all classmates'
		else  
			render action: :new
	  end
  end
end
