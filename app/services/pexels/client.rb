require "net/http"
require "json"

module Pexels
  class Client
    BASE_URL = "https://api.pexels.com/v1"

    class Error < StandardError; end

    def search_photos(query:, page: 1, per_page: 12)
      return [] if query.blank?

      response = get("/search", query: query, page: page, per_page: per_page, orientation: "landscape", size: "medium", locale: "en-US")
      response.fetch("photos", []).filter_map { |photo| photo_summary(photo) }
    end

    private

    def get(path, params = {})
      raise Error, missing_api_key_message if api_key.blank?

      uri = URI("#{BASE_URL}#{path}")
      uri.query = URI.encode_www_form(params.compact)

      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"
      request["Authorization"] = api_key

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 8) do |http|
        http.request(request)
      end

      raise Error, invalid_api_key_message if response.code == "401"
      raise Error, "Pexels rate limit reached. Try again later." if response.code == "429"
      raise Error, "Pexels is temporarily unavailable. Please try again." unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue JSON::ParserError, Timeout::Error, SocketError, Errno::ECONNREFUSED
      raise Error, "Pexels is temporarily unavailable. Please try again."
    end

    def photo_summary(photo)
      src = photo.fetch("src")

      {
        id: photo.fetch("id"),
        image_url: src["large2x"] || src["large"] || src["landscape"],
        thumbnail_url: src["medium"] || src["small"],
        source_url: photo.fetch("url"),
        author: photo.fetch("photographer"),
        author_url: photo.fetch("photographer_url"),
        provider: "Pexels",
        alt: photo["alt"].presence || "Pexels cinema cover image",
        color: photo["avg_color"]
      }
    rescue KeyError
      nil
    end

    def api_key
      ENV["PEXELS_API_KEY"].to_s.strip.presence
    end

    def missing_api_key_message
      "Pexels API key is missing. Add PEXELS_API_KEY to your .env file."
    end

    def invalid_api_key_message
      "Pexels rejected your API key. Check PEXELS_API_KEY in your .env file."
    end
  end
end
