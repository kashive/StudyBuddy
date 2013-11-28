class Notification < ActiveRecord::Base
  attr_accessible :action, :host_id, :notifiable_type, :notifiable_id, :user_id, :seen
  belongs_to :notifiable, polymorphic: true
end
