class Message < ActiveRecord::Base
  attr_accessible :message, :receiver_id, :sender_id
end
