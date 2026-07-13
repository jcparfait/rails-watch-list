require "test_helper"

class MovieReviewTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "reviewer@example.com", password: "password")
    @movie = Movie.create!(title: "Inception", overview: "Dream heist", tmdb_id: 27205)
  end

  test "requires a rating between 0 and 5" do
    review = MovieReview.new(movie: @movie, user: @user, content: "Great film", rating: 6)

    assert_not review.valid?
    assert_includes review.errors[:rating], "must be less than or equal to 5"
  end

  test "requires content" do
    review = MovieReview.new(movie: @movie, user: @user, rating: 4)

    assert_not review.valid?
    assert_includes review.errors[:content], "can't be blank"
  end

  test "allows only one review per user and movie" do
    MovieReview.create!(movie: @movie, user: @user, content: "First review", rating: 5)

    duplicate = MovieReview.new(movie: @movie, user: @user, content: "Second review", rating: 4)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:movie_id], "has already been taken"
  end
end
