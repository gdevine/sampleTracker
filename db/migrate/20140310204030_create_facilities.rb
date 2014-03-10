class CreateFacilities < ActiveRecord::Migration
  def change
    create_table :facilities do |t|
      t.string :code
      t.string :description
      t.integer :contact_id

      t.timestamps
    end
    add_index :facilities, [:code]
  end
end
