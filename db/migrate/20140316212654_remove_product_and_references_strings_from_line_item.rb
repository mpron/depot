class RemoveProductAndReferencesStringsFromLineItem < ActiveRecord::Migration
  def change
    remove_column :line_items, :product, :string
    remove_column :line_items, :references, :string
  end
end
