class MovieReviewsController < ApplicationController
  def create
    movie = Movie.find(params.require(:movie_id))
    movie_review = movie.movie_reviews.find_or_initialize_by(user: current_user)
    movie_review.assign_attributes(movie_review_params)

    if movie_review.save
      redirect_to list_path(params.require(:list_id), anchor: "movie-#{movie.id}"), notice: "Your review for #{movie.title} was saved."
    else
      redirect_to list_path(params.require(:list_id), anchor: "movie-#{movie.id}"), alert: movie_review.errors.full_messages.to_sentence
    end
  end

  def destroy
    movie_review = current_user.movie_reviews.find(params[:id])
    movie = movie_review.movie
    movie_review.destroy

    redirect_to list_path(params.require(:list_id), anchor: "movie-#{movie.id}"), notice: "Your review for #{movie.title} was deleted.", status: :see_other
  end

  private

  def movie_review_params
    params.require(:movie_review).permit(:rating, :content)
  end
end
