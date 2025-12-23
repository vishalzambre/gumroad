# frozen_string_literal: true

class OfferCodesController < ApplicationController
  def compute_discount
    purchaser_email = params[:email] || (logged_in_user&.email)
    purchaser_id = logged_in_user&.id
    response = OfferCodeDiscountComputingService.new(
      params[:code],
      params[:products],
      purchaser_email: purchaser_email,
      purchaser_id: purchaser_id
    ).process
    response = if response[:error_code].present?
      error_message = case response.fetch(:error_code)
                      when :insufficient_times_of_use
                        "Sorry, the discount code you are using is invalid for the quantity you have selected."
                      when :sold_out
                        "Sorry, the discount code you wish to use has expired."
                      when :invalid_offer
                        "Sorry, the discount code you wish to use is invalid."
                      when :inactive
                        "Sorry, the discount code you wish to use is inactive."
                      when :unmet_minimum_purchase_quantity
                        "Sorry, the discount code you wish to use has an unmet minimum quantity."
                      when :required_product_not_owned
                        required_product = OfferCode.find_by(code: params[:code])&.required_product
                        product_name = required_product&.name || "the required product"
                        "Sorry, this discount code is only available to customers who own #{product_name}."
      end
      { valid: false, error_code: response[:error_code], error_message: }
    else
      { valid: true, products_data: response[:products_data].transform_values { _1[:discount] } }
    end

    render json: response
  end
end
