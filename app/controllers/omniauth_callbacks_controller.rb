class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    user = User.from_omniauth(request.env["omniauth.auth"])
    begin
      alreadyExist = User.where("email = '#{user.email}'").first!
    rescue ActiveRecord::RecordNotFound
    end
    if user.persisted? && user.email[-13..-1] == "@brandeis.edu" && alreadyExist == nil
      flash.notice = "Signed in!" if user.confirmed_at != nil
      sign_in_and_redirect user
    elsif (alreadyExist != nil)
      alreadyExist.provider = user.provider
      alreadyExist.uid = user.uid
      alreadyExist.save
      flash.notice = "Signed in!" if alreadyExist.confirmed_at != nil
      sign_in_and_redirect alreadyExist
    else
      session["devise.user_attributes"] = user.attributes
      user.destroy
      redirect_to new_user_registration_url, :alert=>"Error Occured!! Please check if Facebook primary email addresss is @brandeis.edu"
    end
  end
  alias_method :facebook, :all
end