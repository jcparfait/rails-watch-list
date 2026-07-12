require "net/http"
require "json"

module Tmdb
  class Client
    BASE_URL = "https://api.themoviedb.org/3"
    IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500"

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
      uri = URI("#{BASE_URL}#{path}")
      params[:api_key] = ENV["TMDB_API_KEY"] if ENV["TMDB_API_TOKEN"].blank?
      uri.query = URI.encode_www_form(params.compact)

      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"
      request["Authorization"] = "Bearer #{ENV.fetch('TMDB_API_TOKEN')}" if ENV["TMDB_API_TOKEN"].present?

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 8) do |http|
        http.request(request)
      end

      raise Error, "TMDB credentials are missing." if response.code == "401"
      raise Error, "TMDB is temporarily unavailable." unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue KeyError
      raise Error, "Add TMDB_API_TOKEN or TMDB_API_KEY to your .env file."
    rescue JSON::ParserError, Timeout::Error, SocketError, Errno::ECONNREFUSED
      raise Error, "TMDB is temporarily unavailable. Please try again."
    end

    def image_url(path)
      path.present? ? "#{IMAGE_BASE_URL}#{path}" : nil
    end

    def backdrop_url(path)
      path.present? ? "https://image.tmdb.org/t/p/w1280#{path}" : nil
    end
  end
end
