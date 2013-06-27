# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
StudyBuddy::Application.initialize!
# Settings for the mailer
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = { 
									:address => "smtp.gmail.com",
									:port => 587,
									:domain => "gmail.com",
									:user_name => "study.collaborate", :password => "collaborate12",
									:authentication => "plain", :enable_starttls_auto => true 
									}