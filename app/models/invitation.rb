class Invitation < ActiveRecord::Base
  attr_accessible :course_id, :host_id, :status, :study_session_id, :user_id
  has_many :notifications, as: :notifiable
end
