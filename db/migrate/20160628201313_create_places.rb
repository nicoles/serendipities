class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.integer :moves_id
      t.string  :name
      t.string  :source
      t.string  :source_guid
      t.decimal :latitude,  precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false

      t.timestamps
    end
  end
end
