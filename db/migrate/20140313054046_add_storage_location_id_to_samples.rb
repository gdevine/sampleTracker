class AddStorageLocationIdToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :storage_location_id, :integer
  end
end
