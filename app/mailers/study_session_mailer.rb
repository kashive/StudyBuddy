class StudySessionMailer < ActionMailer::Base
  default from: "study.collaborate@gmail.com"
  def study_session_invite(study_session,user)
    @study_session = study_session
    @course = @study_session.getCourse
    @user = user
    # @url = user_course_study_session_path(@user,@course,@study_session)
    mail(to: @user.email, subject: "You've been invited for a study session for #{@course.name}")
  end
end