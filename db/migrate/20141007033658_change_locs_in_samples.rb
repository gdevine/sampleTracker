class ChangeLocsInSamples < ActiveRecord::Migration
  def up
    remove_column :samples, :northing 
    remove_column :samples, :easting
    remove_column :samples, :vertical
    add_column :samples, :northing, :float 
    add_column :samples, :easting, :float
    add_column :samples, :vertical, :float
  end

  def down
    remove_column :samples, :northing 
    remove_column :samples, :easting
    remove_column :samples, :vertical
    add_column :samples, :northing, :string
    add_column :samples, :easting, :string
    add_column :samples, :vertical, :string
  end
end
