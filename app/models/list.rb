class List < ApplicationRecord
  belongs_to :user

  has_many :bookmarks, dependent: :destroy
  has_many :movies, through: :bookmarks
  has_many :reviews, dependent: :destroy

  has_one_attached :photo

  validates :name, presence: true, uniqueness: { scope: :user_id }

  def selected_cover_payload=(payload)
    apply_pexels_cover_payload(payload)
  end

  private

  def apply_pexels_cover_payload(payload)
    return if payload.blank?

    cover = JSON.parse(payload).with_indifferent_access
    image_url = cover[:image_url].to_s
    source_url = cover[:source_url].to_s
    author_url = cover[:author_url].to_s

    return unless cover[:provider].to_s == "Pexels"
    return unless image_url.start_with?("https://images.pexels.com/")
    return unless source_url.start_with?("https://www.pexels.com/")
    return unless author_url.blank? || author_url.start_with?("https://www.pexels.com/")

    assign_attributes(
      cover_image_url: image_url,
      cover_image_author: cover[:author].to_s,
      cover_image_author_url: author_url,
      cover_image_source_url: source_url,
      cover_image_provider: "Pexels",
      cover_image_alt: cover[:alt].to_s,
      cover_image_color: cover[:color].to_s
    )
  rescue JSON::ParserError
    nil
  end
end
