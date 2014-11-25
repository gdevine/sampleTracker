class ChangeRoomFormatInStorageLocation < ActiveRecord::Migration
  def up
    change_column :storage_locations, :room, :string
  end

  def down
    change_column :storage_locations, :room, :integer
  end
end
