class AddNumSamplesToSampleSets < ActiveRecord::Migration
  def change
    add_column :sample_sets, :num_samples, :integer
  end
end
