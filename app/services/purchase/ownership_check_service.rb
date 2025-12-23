# frozen_string_literal: true

class Purchase::OwnershipCheckService
  def initialize(product_id:, email: nil, user_id: nil)
    @product_id = product_id
    @email = email
    @user_id = user_id
  end

  def owns_product?
    earliest_purchase_date.present?
  end

  def earliest_purchase_date
    @_earliest_purchase_date ||= find_earliest_purchase_date
  end

  def ownership_duration_months
    return nil unless earliest_purchase_date

    months_since_purchase = ((Time.current - earliest_purchase_date) / 1.month).round(2)
    months_since_purchase
  end

  private
    attr_reader :product_id, :email, :user_id

    def find_earliest_purchase_date
      purchases = Purchase.where(link_id: product_id)
                          .where(purchase_state: Purchase::ALL_SUCCESS_STATES)
                          .not_fully_refunded
                          .not_chargedback

      if user_id.present?
        purchases = purchases.where(purchaser_id: user_id)
      end

      if email.present?
        purchases = purchases.or(Purchase.where(link_id: product_id, email: email)
                                         .where(purchase_state: Purchase::ALL_SUCCESS_STATES)
                                         .not_fully_refunded
                                         .not_chargedback)
      end

      purchases.minimum(:created_at)
    end
end
