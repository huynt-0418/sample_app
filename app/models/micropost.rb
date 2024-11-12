class Micropost < ApplicationRecord
  PERMITTED_PARAMS = [:content, :image].freeze

  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: Settings.default.image.size
  end

  allowed_image_types = Rails.application.config_for(:settings).dig(:default, :image, :types)

  validates :content, presence: true, length: { maximum: Settings.default.digit_140 }
  validates :image, content_type: { in: allowed_image_types,
                                    message: I18n.t("views.microposts.image_format") },
                    size: { less_than: Settings.default.image.fileSize.megabytes,
                            message: I18n.t("views.microposts.image_size") }
  scope :newest, ->{order created_at: :desc}
end
