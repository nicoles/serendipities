class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.integer :moves_id
      t.string  :name
      t.string  :place_type
      t.string  :facebook_place_id
      t.string  :foursquare_id
      t.string  :foursquare_category_ids, array: true
      t.decimal :latitude,  precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false

      t.timestamps
    end

    add_index  :places, :foursquare_category_ids, using: 'gin'
  end
end
