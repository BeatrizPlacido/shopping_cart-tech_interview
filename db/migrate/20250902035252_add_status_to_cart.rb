class AddStatusToCart < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :string
  end
end
