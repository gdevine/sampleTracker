class RemoveFieldsFromSamples < ActiveRecord::Migration
  def change
    remove_column :samples, :northing, :float
    remove_column :samples, :easting, :float
    remove_column :samples, :vertical, :float
  end
end
