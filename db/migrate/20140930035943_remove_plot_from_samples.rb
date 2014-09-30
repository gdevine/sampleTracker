class RemovePlotFromSamples < ActiveRecord::Migration
  def change
    remove_column :samples, :plot, :integer
  end
end
