class RemoveContainerFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_reference :products, :container, index: true
  end
end
