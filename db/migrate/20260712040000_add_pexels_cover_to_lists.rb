class AddPexelsCoverToLists < ActiveRecord::Migration[8.1]
  def change
    add_column :lists, :cover_image_url, :text
    add_column :lists, :cover_image_author, :string
    add_column :lists, :cover_image_author_url, :text
    add_column :lists, :cover_image_source_url, :text
    add_column :lists, :cover_image_provider, :string
    add_column :lists, :cover_image_alt, :string
    add_column :lists, :cover_image_color, :string
  end
end
