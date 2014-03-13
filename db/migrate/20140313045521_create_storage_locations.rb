class CreateStorageLocations < ActiveRecord::Migration
  def change
    create_table :storage_locations do |t|
      t.string :code
      t.string :building
      t.integer :room
      t.text :description
      t.integer :custodian_id
      t.text :address

      t.timestamps
    end
  end
end
