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
      redirect_to list_path(list), notice: "#{movie.title} was added to your collection.", status: :see_other
    else
      redirect_to list_movie_search_path(list, query: movie.title), alert: bookmark.errors.full_messages.to_sentence, status: :see_other
    end
  rescue Tmdb::Client::Error, ActiveRecord::RecordInvalid, ActionController::ParameterMissing, ActiveRecord::RecordNotFound => e
    list = current_user.lists.find_by(id: params[:list_id])
    destination = list ? list_movie_search_path(list) : lists_path

    redirect_to destination, alert: e.message, status: :see_other
  end
end
