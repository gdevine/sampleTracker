class AddFieldsToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :northing, :string
    add_column :samples, :easting, :string
    add_column :samples, :vertical, :string
  end
end
