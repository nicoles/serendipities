class CreateOauthCredentials < ActiveRecord::Migration
  def change
    create_table :oauth_credentials do |t|
      t.string :type
      t.string :uid
      t.integer :user_id
      t.string :token
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
