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
end
