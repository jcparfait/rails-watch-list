class MovieImportsController < ApplicationController
  def create
    list = current_user.lists.find(params[:list_id])
    attributes = Tmdb::Client.new.movie_details(params.require(:tmdb_id))

    movie = Movie.find_or_initialize_by(tmdb_id: attributes[:tmdb_id])
    movie.assign_attributes(attributes)
    movie.save!

    bookmark = list.bookmarks.find_or_initialize_by(movie: movie)
    bookmark.comment = params[:comment].presence || "Saved from TMDB search."

    if bookmark.save
      redirect_to list, notice: "#{movie.title} was added to your collection."
    else
      redirect_to list_movie_search_path(list, query: movie.title), alert: bookmark.errors.full_messages.to_sentence
    end
  rescue Tmdb::Client::Error, ActiveRecord::RecordInvalid, ActionController::ParameterMissing, ActiveRecord::RecordNotFound => e
    list = current_user.lists.find_by(id: params[:list_id])
    redirect_to(list ? list_movie_search_path(list) : lists_path, alert: e.message)
  end
end
