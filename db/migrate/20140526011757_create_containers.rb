class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.string :container_type
      t.text :description
      t.integer :storage_location_id
      t.integer :owner_id

      t.timestamps
    end
    add_index :containers, [:owner_id, :created_at]
  end
end
