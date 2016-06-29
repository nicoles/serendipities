class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer  :segment_id, null: false
      t.string   :type, null: false
      t.string   :group
      t.integer  :duration
      t.integer  :distance
      t.integer  :calories
      t.integer  :steps
      t.boolean  :manual
      t.json     :track_points

      t.timestamps
    end
  end
end
