class AddFieldsToSampleSets < ActiveRecord::Migration
  def change
    add_column :sample_sets, :status, :string
    add_column :sample_sets, :add_info, :text
  end
end
