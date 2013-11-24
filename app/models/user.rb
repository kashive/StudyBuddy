class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  before_save :ensure_authentication_token
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,:confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :college,
  :major_minors,:exp_graduation_date,:gender,:highschool,:about_yourself,:contact_number, :authentication_token
  # attr_accessible :title, :body
  has_many :enrollments
  has_many :courses, through: :enrollments, dependent: :destroy
  has_many :study_sessions, through: :courses, dependent: :destroy

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  private
    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(authentication_token: token).first
      end
    end
end

