class RegistrationsController < Devise::RegistrationsController	
  def create
  	a = super
  	if a.size == 86 || a.size == 92
  		@user = User.order("created_at desc").first
  		@user.create_activity :create, owner: @user
  	end
  end

  protected

	def after_update_path_for(resource)
	  edit_user_registration_path(resource)
	end
end