class AddParentIdToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :parent_id, :integer
  end
end
