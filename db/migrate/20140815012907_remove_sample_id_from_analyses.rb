class RemoveSampleIdFromAnalyses < ActiveRecord::Migration
  def change
    remove_column :analyses, :sample_id, :integer
  end
end
