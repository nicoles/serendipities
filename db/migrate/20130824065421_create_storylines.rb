class CreateStorylines < ActiveRecord::Migration
  def change
    create_table :storylines do |t|
      t.integer :user_id
      t.date :story_date
      t.json :moves_data

      t.timestamps
    end
  end
end
