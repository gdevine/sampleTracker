class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.integer :sample_set_id
      t.integer :owner_id
      t.boolean :sampled
      t.date    :date_sampled
      t.integer :storage_location
      t.integer :facility_id
      t.integer :project_id
      t.text    :comments
      t.boolean :is_primary
      t.integer :ring
      t.integer :tree
      t.integer :plot
      t.float   :northing
      t.float   :easting
      t.float   :vertical
      t.string  :material_type
      t.string  :amount_collected
      t.string  :amount_stored

      t.timestamps
    end
    add_index :samples, [:owner_id, :created_at]
  end
end
