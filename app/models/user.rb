class User < ActiveRecord::Base
  include PublicActivity::Common
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  before_save :ensure_authentication_token
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,:confirmable,:omniauthable
  before_destroy :deleteCourses, :deleteNotifications, :deleteAllActivities

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :college,
  :major_minors,:exp_graduation_date,:gender,:highschool,:about_yourself,:contact_number, :authentication_token
  # attr_accessible :title, :body
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments, dependent: :destroy
  has_many :study_sessions, through: :courses, dependent: :destroy

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end


  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.oauth_token = auth.credentials.token
      user.first_name = auth["info"]["first_name"]
      user.last_name  = auth["info"]["last_name"]
      user.image  = auth["info"]["image"]
      user.email = auth["info"]["email"]
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.college = "Brandeis University"
    end
  end

  # this method takes in a user_id and returns back the first class the self has in common with the user_id
  def firstCommonClass(user_id)
    # get all of the self's courses and get all of the user_id's courses and see if there is any commonality and get the first commonality
    coursesForSelf = Course.where("user_id = '#{self.id}'")
    coursesForUserId = Course.where("user_id = '#{user_id.to_s}'")
    coursesForSelf.each do |courseForSelf|
      coursesForUserId.each do |courseForUserId|
        if courseForSelf.name == courseForUserId.name
          return courseForUserId.name
        end
      end
    end
    return nil
  end

  # this method returns all the classmates for the user
  def getAllClassmates
    # get all user courses and for each course get all the classmates, remove duplicates and the self user from the array before sending it back
    allClassmates = []
    courses = Course.where("user_id = '#{self.id}'")
    courses.each do |course|
      course.getClassmates.each do |classmate|
        allClassmates.push(classmate)
      end
    end
    return (allClassmates - [self]).uniq
  end

  def deleteCourses
    courses = Course.where("user_id = '#{self.id}'")
    courses.each do |course| course.destroy end
  end

  def deleteAllActivities
    activities = PublicActivity::Activity.where("owner_id = '#{self.id}' AND owner_type= 'User'")
    activities.each do |activity| activity.destroy end
  end

  def deleteNotifications
    notifications = Notification.where("user_id = '#{self.id}' OR host_id = '#{self.id}'")
    notifications.each do |notification| notification.destroy end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end  

  def facebook
    @facebook ||= Koala::Facebook::API.new(oauth_token)
    block_given? ? yield(@facebook) : @facebook
    @facebook.exchange_access_token(oauth_token)
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
    nil # or consider a custom null object
  end

  def friends_count
    facebook { |fb| fb.get_connection("me", "friends").size }
  end



  private
    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(authentication_token: token).first
      end
    end
end

