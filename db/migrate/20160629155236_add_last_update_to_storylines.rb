class AddLastUpdateToStorylines < ActiveRecord::Migration
  def change
    add_column :storylines, :last_update, :datetime
    add_column :storylines, :calories_idle, :integer
  end
end
