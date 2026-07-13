# Idempotent demo data for local setup and portfolio deployments.
#
# Optional environment variables:
#   DEMO_USER_EMAIL=demo@example.com
#   DEMO_USER_PASSWORD=your-password

puts "Seeding Reelist demo data..."

user_email = ENV.fetch("DEMO_USER_EMAIL", "demo@reelist.app")
user_password = ENV.fetch("DEMO_USER_PASSWORD", "password")

user = User.find_or_initialize_by(email: user_email)
user.name = "Demo User" if user.name.blank?
user.password = user_password if user.encrypted_password.blank? || ENV["DEMO_USER_PASSWORD"].present?
user.save!

movies = [
  {
    tmdb_id: 78,
    title: "Blade Runner",
    overview: "In a rain-soaked future Los Angeles, a blade runner tracks synthetic humans while questioning what makes a life real.",
    poster_url: "https://image.tmdb.org/t/p/w500/63N9uy8nd9j7Eog2axPQ8lbr3Wj.jpg",
    rating: 7.9
  },
  {
    tmdb_id: 157336,
    title: "Interstellar",
    overview: "A team of explorers travels through a wormhole in search of a future for humanity.",
    poster_url: "https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
    rating: 8.4
  },
  {
    tmdb_id: 27205,
    title: "Inception",
    overview: "A thief who steals secrets through dreams is offered a final job that could give him his life back.",
    poster_url: "https://image.tmdb.org/t/p/w500/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg",
    rating: 8.4
  },
  {
    tmdb_id: 496243,
    title: "Parasite",
    overview: "A poor family infiltrates a wealthy household, setting off a sharp social thriller.",
    poster_url: "https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg",
    rating: 8.5
  },
  {
    tmdb_id: 603,
    title: "The Matrix",
    overview: "A hacker discovers the world he knows may be a simulation and joins a rebellion against its controllers.",
    poster_url: "https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
    rating: 8.2
  },
  {
    tmdb_id: 550,
    title: "Fight Club",
    overview: "An office worker and a soap maker form an underground club that spirals into something far more dangerous.",
    poster_url: "https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
    rating: 8.4
  }
]

movies_by_title = movies.each_with_object({}) do |attributes, memo|
  movie = Movie.find_or_initialize_by(tmdb_id: attributes[:tmdb_id])
  movie.assign_attributes(attributes)
  movie.save!
  memo[attributes[:title]] = movie
end

collections = [
  {
    name: "Science Fiction",
    cover_image_url: "https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?auto=compress&cs=tinysrgb&w=1600",
    cover_image_author: "Tima Miroshnichenko",
    cover_image_author_url: "https://www.pexels.com/@tima-miroshnichenko/",
    cover_image_source_url: "https://www.pexels.com/photo/people-watching-movie-in-cinema-7991579/",
    cover_image_provider: "Pexels",
    cover_image_alt: "People watching a movie in a cinema",
    movie_titles: [ "Blade Runner", "Interstellar", "The Matrix" ]
  },
  {
    name: "Mind Benders",
    cover_image_url: "https://images.pexels.com/photos/7991312/pexels-photo-7991312.jpeg?auto=compress&cs=tinysrgb&w=1600",
    cover_image_author: "Tima Miroshnichenko",
    cover_image_author_url: "https://www.pexels.com/@tima-miroshnichenko/",
    cover_image_source_url: "https://www.pexels.com/photo/person-holding-clapper-board-7991312/",
    cover_image_provider: "Pexels",
    cover_image_alt: "Cinema clapperboard",
    movie_titles: [ "Inception", "Fight Club" ]
  },
  {
    name: "Critics Night",
    cover_image_url: "https://images.pexels.com/photos/7991184/pexels-photo-7991184.jpeg?auto=compress&cs=tinysrgb&w=1600",
    cover_image_author: "Tima Miroshnichenko",
    cover_image_author_url: "https://www.pexels.com/@tima-miroshnichenko/",
    cover_image_source_url: "https://www.pexels.com/photo/people-in-a-cinema-7991184/",
    cover_image_provider: "Pexels",
    cover_image_alt: "Cinema seats and projection light",
    movie_titles: [ "Parasite", "Blade Runner" ]
  }
]

collections.each do |attributes|
  movie_titles = attributes.delete(:movie_titles)
  list = user.lists.find_or_initialize_by(name: attributes[:name])
  list.assign_attributes(attributes)
  list.save!

  movie_titles.each do |title|
    movie = movies_by_title.fetch(title)
    Bookmark.find_or_create_by!(list: list, movie: movie) do |bookmark|
      bookmark.comment = "Added to #{list.name} for demo browsing."
    end
  end
end

puts "Finished seeding #{User.count} users, #{List.count} collections and #{Movie.count} movies."
