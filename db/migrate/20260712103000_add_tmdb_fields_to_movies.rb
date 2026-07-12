class AddTmdbFieldsToMovies < ActiveRecord::Migration[8.1]
  def change
    remove_index :movies, :title if index_exists?(:movies, :title)

    add_column :movies, :tmdb_id, :integer
    add_column :movies, :backdrop_url, :string
    add_column :movies, :release_date, :date
    add_column :movies, :runtime, :integer
    add_column :movies, :genres, :string
    add_column :movies, :original_language, :string

    add_index :movies, :tmdb_id, unique: true
    add_index :movies, :title
  end
end
