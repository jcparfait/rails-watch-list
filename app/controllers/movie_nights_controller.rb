class MovieNightsController < ApplicationController
  before_action :load_form_data, only: [ :new, :create ]

  def new
  end

  def create
    @mood = movie_night_params[:mood]
    @duration = movie_night_params[:duration]
    @genre = movie_night_params[:genre]

    @movie = MovieNight::Recommender.new.call(
      mood: @mood,
      duration: @duration,
      genre: @genre,
      excluded_tmdb_ids: session[:movie_night_seen_tmdb_ids] || []
    )

    session[:movie_night_seen_tmdb_ids] = ((session[:movie_night_seen_tmdb_ids] || []) + [ @movie[:tmdb_id] ]).last(30)

    flash.now[:notice] = "We found a film for tonight."
    render :new, status: :ok
  rescue MovieNight::Recommender::Error, Tmdb::Client::Error, ActionController::ParameterMissing => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def save
    list = current_user.lists.find(params.require(:list_id))
    attributes = Tmdb::Client.new.movie_details(params.require(:tmdb_id))

    movie = Movie.find_or_initialize_by(tmdb_id: attributes[:tmdb_id])
    movie.assign_attributes(attributes)
    movie.save!

    bookmark = list.bookmarks.find_or_initialize_by(movie: movie)
    bookmark.comment = params[:comment].presence || "Recommended by Movie Night."

    if bookmark.save
      redirect_to list_path(list), notice: "#{movie.title} was saved to #{list.name}.", status: :see_other
    else
      redirect_to movie_night_path, alert: bookmark.errors.full_messages.to_sentence, status: :see_other
    end
  rescue Tmdb::Client::Error, ActiveRecord::RecordInvalid, ActionController::ParameterMissing, ActiveRecord::RecordNotFound => e
    redirect_to movie_night_path, alert: e.message, status: :see_other
  end

  private

  def load_form_data
    @mood_options = MovieNight::Recommender.mood_options
    @duration_options = MovieNight::Recommender.duration_options
    @genre_options = MovieNight::Recommender.genre_options
    @lists = current_user.lists.order(:name)
  end

  def movie_night_params
    params.require(:movie_night).permit(:mood, :duration, :genre)
  end
end
