require "bcrypt"
require "securerandom"

class CreateUsersAndAddOwnership < ActiveRecord::Migration[8.1]
  def up
    create_table :users do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true

    add_reference :lists, :user, foreign_key: true
    add_reference :reviews, :user, foreign_key: true

    legacy_user_id = create_legacy_user
    execute "UPDATE lists SET user_id = #{legacy_user_id} WHERE user_id IS NULL"
    execute "UPDATE reviews SET user_id = #{legacy_user_id} WHERE user_id IS NULL"

    change_column_null :lists, :user_id, false
    change_column_null :reviews, :user_id, false

    remove_index :lists, :name
    add_index :lists, [ :user_id, :name ], unique: true
  end

  def down
    remove_index :lists, [ :user_id, :name ]
    add_index :lists, :name, unique: true

    remove_reference :reviews, :user, foreign_key: true
    remove_reference :lists, :user, foreign_key: true
    drop_table :users
  end

  private

  def create_legacy_user
    email = "legacy@reelist.local"
    password = BCrypt::Password.create(SecureRandom.hex(32))
    now = connection.quote(Time.current)

    execute <<~SQL.squish
      INSERT INTO users (email, encrypted_password, created_at, updated_at)
      VALUES (#{connection.quote(email)}, #{connection.quote(password)}, #{now}, #{now})
    SQL

    select_value("SELECT id FROM users WHERE email = #{connection.quote(email)}")
  end
end
