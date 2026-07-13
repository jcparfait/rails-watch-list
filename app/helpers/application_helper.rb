module ApplicationHelper
  DEFAULT_META_TITLE = "Reelist — Build your personal cinema library".freeze
  DEFAULT_META_DESCRIPTION = "Create movie collections, import films from TMDB, choose cinematic covers and find the right film for tonight.".freeze
  DEFAULT_OG_IMAGE_CANDIDATES = [
    "social/og-image.png",
    "social/og-image.jpg",
    "social/og-image.jpeg",
    "social/og-image.svg",
    "og-image.png",
    "cover.png"
  ].freeze
  DEFAULT_FAVICON_CANDIDATES = [
    "favicon.ico",
    "favicon.png",
    "favicon/favicon.ico",
    "favicon/favicon-32x32.png",
    "logo/logoreelist.png"
  ].freeze
  DEFAULT_APPLE_TOUCH_ICON_CANDIDATES = [
    "apple-touch-icon.png",
    "favicon/apple-touch-icon.png",
    "favicon/favicon-180x180.png",
    "logo/logoreelist.png"
  ].freeze

  def asset_available?(logical_path)
    if Rails.application.config.assets.compile
      Rails.application.assets&.find_asset(logical_path).present?
    else
      Rails.application.assets_manifest.find_sources(logical_path).any?
    end
  rescue StandardError
    false
  end

  def first_available_asset(*logical_paths)
    logical_paths.flatten.find { |logical_path| asset_available?(logical_path) }
  end

  def meta_title
    content_for(:title).presence || DEFAULT_META_TITLE
  end

  def meta_description
    content_for(:description).presence || DEFAULT_META_DESCRIPTION
  end

  def meta_image_url
    logical_path = first_available_asset(DEFAULT_OG_IMAGE_CANDIDATES)
    return unless logical_path.present?

    asset_url(logical_path)
  end

  def favicon_asset_path
    first_available_asset(DEFAULT_FAVICON_CANDIDATES)
  end

  def apple_touch_icon_asset_path
    first_available_asset(DEFAULT_APPLE_TOUCH_ICON_CANDIDATES)
  end

  def list_cover_image_source(list)
    return list.cover_image_url if list.cover_image_url.present?
    return url_for(list.photo) if list.photo.attached?

    nil
  end

  def list_card_background_style(list)
    overlay = "linear-gradient(180deg, rgba(20, 11, 18, 0.08), rgba(20, 11, 18, 0.92))"
    image_url = list_cover_image_source(list)
    layers = [ overlay ]
    layers << "url('#{image_url}')" if image_url.present?

    "background-image: #{layers.join(', ')};"
  end

  def list_cover_alt(list)
    list.cover_image_alt.presence || "#{list.name} collection cover"
  end

  def pexels_cover_credit?(list)
    list.cover_image_provider == "Pexels" && list.cover_image_author.present?
  end

  def pexels_cover_credit_text(list)
    "Photo by #{list.cover_image_author} on Pexels"
  end

  def pexels_cover_credit_url(list)
    list.cover_image_source_url.presence || "https://www.pexels.com"
  end
end
