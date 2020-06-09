class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  devise :omniauthable, omniauth_providers: [:google_oauth2]

  # validate username
  validates :username, presence: true, uniqueness: { case_sensitive: false }

  #To allow users to login with username or email
  attr_writer :login

  def login
    @login || self.username || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  # Only allow letter, number, underscore and punctuation.
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

  # Prevent username to have someone else is email as username
  validate :validate_username

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  # Oauth with google
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.username = auth.info.email.split("@")[0]
      # user.birthday = auth.info.birthday # TODO
      # user.name = auth.info.name   # assuming the user model has a name
      user.avatar = auth.info.image  # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      user.skip_confirmation!
    end
  end

  # User Profile image
  has_one_attached :avatar
  after_commit :add_default_avatar, on: %i[create update]

  def avatar_thumbnail
    avatar.variant(resize: "150x150!").processed
  end

  def add_default_avatar
    unless avatar.attached?
      avatar.attach(
        io: File.open(
          Rails.root.join(
            "app", "assets", "images", "default_profile.jpg"
          )
        ),
        filename: "default_profile.jpg",
        content_type: "image/jpg",
      )
    end
  end

  def validBirthday
    if birthday.to_date > Date.today
      errors.add(:birthday, "Invalid birthday")
    end
  end

  validate :validBirthday

  # TODO Controlla che i seguenti campi non siano vuoti
  # validates :birthday, presence: true
end
