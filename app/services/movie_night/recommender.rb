module MovieNight
  class Recommender
    MOODS = {
      "feel_good" => { label: "Feel good", genre_ids: [ 35, 10751, 12 ] },
      "intense" => { label: "Intense", genre_ids: [ 28, 53, 80 ] },
      "thoughtful" => { label: "Thought-provoking", genre_ids: [ 18, 878, 99 ] },
      "romantic" => { label: "Romantic", genre_ids: [ 10749, 35, 18 ] },
      "funny" => { label: "Funny", genre_ids: [ 35, 16, 12 ] },
      "suspenseful" => { label: "Suspenseful", genre_ids: [ 53, 9648, 27 ] }
    }.freeze

    DURATIONS = {
      "short" => { label: "Less than 90 min", runtime_lte: 90 },
      "standard" => { label: "90–120 min", runtime_gte: 90, runtime_lte: 120 },
      "long" => { label: "More than 120 min", runtime_gte: 120 }
    }.freeze

    GENRES = {
      "action" => { label: "Action", id: 28 },
      "adventure" => { label: "Adventure", id: 12 },
      "comedy" => { label: "Comedy", id: 35 },
      "crime" => { label: "Crime", id: 80 },
      "drama" => { label: "Drama", id: 18 },
      "horror" => { label: "Horror", id: 27 },
      "mystery" => { label: "Mystery", id: 9648 },
      "romance" => { label: "Romance", id: 10749 },
      "science_fiction" => { label: "Science Fiction", id: 878 },
      "thriller" => { label: "Thriller", id: 53 }
    }.freeze

    class Error < StandardError; end

    def self.mood_options
      MOODS.map { |key, mood| [ mood.fetch(:label), key ] }
    end

    def self.duration_options
      DURATIONS.map { |key, duration| [ duration.fetch(:label), key ] }
    end

    def self.genre_options
      GENRES.map { |key, genre| [ genre.fetch(:label), key ] }
    end

    def initialize(client: Tmdb::Client.new)
      @client = client
    end

    def call(mood:, duration:, genre: nil, excluded_tmdb_ids: [])
      mood_config = MOODS[mood.to_s]
      duration_config = DURATIONS[duration.to_s]

      raise Error, "Choose a mood." if mood_config.blank?
      raise Error, "Choose a duration." if duration_config.blank?

      candidates = client.discover_movies(discover_filters(mood_config, duration_config, genre))
                         .reject { |movie| excluded_tmdb_ids.map(&:to_i).include?(movie.fetch(:tmdb_id).to_i) }
                         .select { |movie| recommendable?(movie) }

      candidates = client.discover_movies(discover_filters(mood_config, duration_config, genre))
                         .select { |movie| recommendable?(movie) } if candidates.empty?

      raise Error, "No recommendation matched these filters. Try another mood or duration." if candidates.empty?

      client.movie_details(candidates.sample.fetch(:tmdb_id))
    end

    private

    attr_reader :client

    def discover_filters(mood_config, duration_config, genre)
      genre_ids = genre_ids_for(mood_config, genre)

      {
        include_adult: false,
        include_video: false,
        language: "en-US",
        page: rand(1..3),
        sort_by: "popularity.desc",
        "vote_average.gte": 6.2,
        "vote_count.gte": 200,
        with_genres: genre_ids.join("|"),
        "with_runtime.gte": duration_config[:runtime_gte],
        "with_runtime.lte": duration_config[:runtime_lte]
      }
    end

    def genre_ids_for(mood_config, genre)
      selected_genre = GENRES[genre.to_s]
      return [ selected_genre.fetch(:id) ] if selected_genre.present?

      mood_config.fetch(:genre_ids)
    end

    def recommendable?(movie)
      movie.fetch(:poster_url).present? && movie.fetch(:overview).present? && movie.fetch(:overview) != "No overview available."
    end
  end
end
