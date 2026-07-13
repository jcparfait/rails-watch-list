class ApplicationController < ActionController::Base
  before_action :redirect_naked_domain_to_www
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  allow_browser versions: :modern
  stale_when_importmap_changes

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  private

  def redirect_naked_domain_to_www
    canonical_host = ENV["APP_HOST"].to_s.strip.downcase
    return unless Rails.env.production?
    return unless canonical_host.start_with?("www.")

    naked_host = canonical_host.delete_prefix("www.")
    return unless request.host.downcase == naked_host

    redirect_to "https://#{canonical_host}#{request.fullpath}", status: :moved_permanently, allow_other_host: true
  end
end
