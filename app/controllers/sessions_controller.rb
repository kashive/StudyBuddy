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
        format.html { redirect_to user_courses_path(current_user), notice: 'You are logged in' }
        format.json { render json: resource.inspect.to_json }
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
      render :json=> {:success=>true}
    else
      render :json=> {:success=>false, :message=>"Logout unsuccessful"}, :status=>401
    end  
  end

  protected

  def invalid_login_attempt
    render :json=> {:success=>false, :message=>"Error with your login or password"}, :status=>401
  end
end