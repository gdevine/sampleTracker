class CreateAnalysesSamples < ActiveRecord::Migration
  def self.up
    create_table :analyses_samples, :id => false do |t|
        t.references :analysis
        t.references :sample
    end
    add_index :analyses_samples, [:analysis_id, :sample_id]
    add_index :analyses_samples, :sample_id
  end

  def self.down
    drop_table :analyses_samples
  end
  
end
