class User < ApplicationRecord
  USER_PARAMS = [:name, :email, :password, :password_confirmation].freeze
  attr_accessor :remember_token

  before_save :downcase_email

  validates :name,
            presence: true,
            length: {maximum: Settings.default.userName.maxLength}
  validates :email,
            presence: true,
            length: {maximum: Settings.default.email.maxLength},
            format: {with: Regexp.new(Settings.default.email.format,
                                      Regexp::IGNORECASE)},
            uniqueness: {case_sensitive: false}
  validates :password, presence: true,
            length: {minimum: Settings.default.password.minLength},
            allow_nil: true

  has_secure_password

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost:)
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column(:remember_digest, User.digest(remember_token))
  end

  def authenticated? remember_token
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_column(:remember_digest, nil)
  end

  private

  def downcase_email
    email.downcase!
  end
end
