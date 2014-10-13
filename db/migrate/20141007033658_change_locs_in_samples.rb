class ChangeLocsInSamples < ActiveRecord::Migration
  def up
    change_column :samples, :northing, :decimal
    change_column :samples, :easting, :decimal
    change_column :samples, :vertical, :decimal
  end

  def down
    change_column :samples, :northing, :string
    change_column :samples, :easting, :string
    change_column :samples, :vertical, :string
  end
end
