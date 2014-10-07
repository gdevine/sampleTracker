class ChangeLocsInSamples < ActiveRecord::Migration
  def up
    change_column :samples, :northing, :float
    change_column :samples, :easting, :float
    change_column :samples, :vertical, :float
  end

  def down
    change_column :samples, :northing, :string
    change_column :samples, :easting, :string
    change_column :samples, :vertical, :string
  end
end
