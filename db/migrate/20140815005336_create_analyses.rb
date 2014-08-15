class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.string :code
      t.string :title
      t.text :description
      t.integer :sample_id

      t.timestamps
    end
  end
end
