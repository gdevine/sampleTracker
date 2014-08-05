class RemoveNumSamplesFromSampleSets < ActiveRecord::Migration
  def change
    remove_column :sample_sets, :num_samples, :integer
  end
end
