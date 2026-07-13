class User < ApplicationRecord
  LEGACY_EMAIL = "legacy@reelist.local"

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :lists, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :movie_reviews, dependent: :destroy

  validates :name, length: { maximum: 80 }

  after_create :claim_legacy_content

  private

  def claim_legacy_content
    legacy_user = User.find_by(email: LEGACY_EMAIL)
    return unless legacy_user
    return if email == LEGACY_EMAIL

    transaction do
      legacy_user.lists.update_all(user_id: id)
      legacy_user.reviews.update_all(user_id: id)
      legacy_user.destroy!
    end
  end
end
