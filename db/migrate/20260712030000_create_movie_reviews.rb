class CreateMovieReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :movie_reviews do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :movie_reviews, [ :movie_id, :user_id ], unique: true
  end
end
