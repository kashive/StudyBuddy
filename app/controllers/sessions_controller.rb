class SessionsController < Devise::SessionsController
  before_filter :authenticate_user!, :except => [:create, :destroy]
  respond_to :json

  def create
    resource = User.find_by_email(params[:user][:email])
    return invalid_login_attempt unless resource
    if resource.valid_password?(params[:user][:password])
      sign_in(:user, resource)
      resource.ensure_authentication_token
      respond_to do |format|
        format.html { redirect_to dashboard_path(current_user), notice: 'You are logged in' }
        format.json { render :json=> { :auth_token=> current_user.authentication_token, :success=> true, :status=> :created }}
      end
      return
    end
    invalid_login_attempt
  end

  def destroy
    resource = current_user
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource))
    if signed_out
      resource.authentication_token = nil
      resource.save
      respond_to do |format|
        format.html{super}
        format.json{render :json=> {:success=>true}}
      end
    else
      respond_to do |format|
        format.html{super}
        format.json{render :json=> {:success=>false, :message=>"Logout unsuccessful", :status=>401}}
      end
    end  
  end

  protected

  def invalid_login_attempt
    redirect_to root_path, alert: 'Login unsuccessful, please check username and/or password!'
  end
end