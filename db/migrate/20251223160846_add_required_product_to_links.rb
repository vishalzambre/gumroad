# frozen_string_literal: true

class AddRequiredProductToLinks < ActiveRecord::Migration[7.1]
  def change
    change_table :links, bulk: true do |t|
      t.bigint :required_product_id
      t.index :required_product_id
    end
  end
end
