class CreateSampleSets < ActiveRecord::Migration
  def change
    create_table :sample_sets do |t|
      t.integer :owner_id
      t.date :sampling_date
      t.integer :num_samples
      t.integer :facility_id
      t.integer :project_id

      t.timestamps
    end
    
    add_index :sample_sets, [:owner_id, :created_at]
  end
end
