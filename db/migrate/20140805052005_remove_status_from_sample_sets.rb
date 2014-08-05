class RemoveStatusFromSampleSets < ActiveRecord::Migration
  def change
    remove_column :sample_sets, :status, :string
  end
end
