# frozen_string_literal: true

class AddRequiredProductToOfferCodes < ActiveRecord::Migration[7.1]
  def change
    change_table :offer_codes, bulk: true do |t|
      t.bigint :required_product_id
      t.integer :required_product_ownership_months_threshold, default: 6
      t.index :required_product_id
    end
  end
end
