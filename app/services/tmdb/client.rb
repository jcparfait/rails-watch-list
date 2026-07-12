require "net/http"
require "json"

module Tmdb
  class Client
    BASE_URL = "https://api.themoviedb.org/3"
    IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500"
    BACKDROP_BASE_URL = "https://image.tmdb.org/t/p/w1280"

    TOKEN_ENV_KEYS = %w[
      TMDB_API_TOKEN
      TMDB_API_READ_ACCESS_TOKEN
      TMDB_READ_ACCESS_TOKEN
      TMDB_ACCESS_TOKEN
    ].freeze

    API_KEY_ENV_KEYS = %w[
      TMDB_API_KEY
      TMDB_KEY
    ].freeze

    class Error < StandardError; end

    def search_movies(query)
      return [] if query.blank?

      response = get("/search/movie", query: query, include_adult: false, language: "en-US")
      response.fetch("results", []).first(12).map do |movie|
        {
          tmdb_id: movie.fetch("id"),
          title: movie.fetch("title"),
          overview: movie["overview"].presence || "No overview available.",
          poster_url: image_url(movie["poster_path"]),
          rating: movie["vote_average"].to_f,
          release_date: movie["release_date"]
        }
      end
    end

    def movie_details(tmdb_id)
      movie = get("/movie/#{Integer(tmdb_id)}", language: "en-US")

      {
        tmdb_id: movie.fetch("id"),
        title: movie.fetch("title"),
        overview: movie["overview"].presence || "No overview available.",
        poster_url: image_url(movie["poster_path"]),
        backdrop_url: backdrop_url(movie["backdrop_path"]),
        rating: movie["vote_average"].to_f,
        release_date: movie["release_date"],
        runtime: movie["runtime"],
        genres: movie.fetch("genres", []).map { |genre| genre.fetch("name") }.join(", "),
        original_language: movie["original_language"]
      }
    end

    private

    def get(path, params = {})
      token = bearer_token
      api_key = v3_api_key

      raise Error, missing_credentials_message if token.blank? && api_key.blank?

      uri = URI("#{BASE_URL}#{path}")
      params[:api_key] = api_key if token.blank?
      uri.query = URI.encode_www_form(params.compact)

      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"
      request["Authorization"] = "Bearer #{token}" if token.present?

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 8) do |http|
        http.request(request)
      end

      raise Error, invalid_credentials_message if response.code == "401"
      raise Error, "TMDB is temporarily unavailable." unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue JSON::ParserError, Timeout::Error, SocketError, Errno::ECONNREFUSED
      raise Error, "TMDB is temporarily unavailable. Please try again."
    end

    def bearer_token
      value = first_present_env_value(TOKEN_ENV_KEYS)
      value&.sub(/\ABearer\s+/i, "")
    end

    def v3_api_key
      first_present_env_value(API_KEY_ENV_KEYS)
    end

    def first_present_env_value(keys)
      keys.map { |key| ENV[key].to_s.strip.presence }.compact.first
    end

    def missing_credentials_message
      "TMDB credentials are missing. Add TMDB_API_TOKEN with your Read Access Token, or TMDB_API_KEY with your API Key, to your .env file."
    end

    def invalid_credentials_message
      "TMDB rejected your credentials. Use the Read Access Token in TMDB_API_TOKEN, without quotes. If it starts with 'Bearer ', you can keep or remove that prefix."
    end

    def image_url(path)
      path.present? ? "#{IMAGE_BASE_URL}#{path}" : nil
    end

    def backdrop_url(path)
      path.present? ? "#{BACKDROP_BASE_URL}#{path}" : nil
    end
  end
end
