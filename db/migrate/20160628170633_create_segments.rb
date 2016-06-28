class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.integer  :storyline_id, null: false
      t.references :segment, polymorphic: true, index: true
      t.boolean  :move, null: false
      t.integer  :place_id #can be null, when move is true

      t.timestamps
    end
  end
end
