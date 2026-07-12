class MovieSearchesController < ApplicationController
  def index
    @list = current_user.lists.find(params[:list_id])
    @query = params[:query].to_s.strip
    @movies = @query.present? ? Tmdb::Client.new.search_movies(@query) : []
  rescue Tmdb::Client::Error => e
    @movies = []
    flash.now[:alert] = e.message
  end
end
