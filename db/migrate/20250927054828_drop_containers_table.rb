class DropContainersTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :containers
  end
end
