class RemoveStorageLocationFromSamples < ActiveRecord::Migration
  def change
    remove_column :samples, :storage_location, :integer
  end
end
