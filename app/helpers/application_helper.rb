module ApplicationHelper
  def asset_available?(logical_path)
    if Rails.application.config.assets.compile
      Rails.application.assets&.find_asset(logical_path).present?
    else
      Rails.application.assets_manifest.find_sources(logical_path).any?
    end
  rescue StandardError
    false
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
