require "test_helper"

class ListTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "owner@example.com", password: "password")
  end

  test "requires a name" do
    list = @user.lists.new

    assert_not list.valid?
    assert_includes list.errors[:name], "can't be blank"
  end

  test "allows the same collection name for different users" do
    @user.lists.create!(name: "Science Fiction")
    other_user = User.create!(email: "other@example.com", password: "password")

    list = other_user.lists.new(name: "Science Fiction")

    assert list.valid?
  end

  test "stores a trusted Pexels cover payload" do
    payload = {
      provider: "Pexels",
      image_url: "https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg",
      source_url: "https://www.pexels.com/photo/people-watching-movie-in-cinema-7991579/",
      author: "Tima Miroshnichenko",
      author_url: "https://www.pexels.com/@tima-miroshnichenko/",
      alt: "People watching a movie",
      color: "#281417"
    }.to_json

    list = @user.lists.new(name: "Cinema", selected_cover_payload: payload)

    assert_equal "https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg", list.cover_image_url
    assert_equal "Tima Miroshnichenko", list.cover_image_author
    assert_equal "Pexels", list.cover_image_provider
  end

  test "ignores untrusted cover payloads" do
    payload = {
      provider: "Pexels",
      image_url: "https://example.com/image.jpg",
      source_url: "https://example.com/photo",
      author_url: "https://example.com/author"
    }.to_json

    list = @user.lists.new(name: "Invalid cover", selected_cover_payload: payload)

    assert_nil list.cover_image_url
  end
end
