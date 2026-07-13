require "test_helper"

class MovieTest < ActiveSupport::TestCase
  test "requires title and overview" do
    movie = Movie.new

    assert_not movie.valid?
    assert_includes movie.errors[:title], "can't be blank"
    assert_includes movie.errors[:overview], "can't be blank"
  end

  test "allows duplicate titles when TMDB ids are different" do
    Movie.create!(title: "King Kong", overview: "1933 version", tmdb_id: 244)

    movie = Movie.new(title: "King Kong", overview: "2005 version", tmdb_id: 254)

    assert movie.valid?
  end

  test "requires tmdb_id to be unique when present" do
    Movie.create!(title: "Blade Runner", overview: "Original film", tmdb_id: 78)

    duplicate = Movie.new(title: "Blade Runner Final Cut", overview: "Duplicate external id", tmdb_id: 78)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:tmdb_id], "has already been taken"
  end
end
