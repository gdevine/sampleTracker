class AddContainerIdToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :container_id, :integer
  end
end
