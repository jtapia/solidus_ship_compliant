Spree::CheckoutController.class_eval do
  rescue_from SolidusShipCompliant::Error do |exception|
    flash[:error] = exception.message
    redirect_to checkout_state_path(:address)
  end
end
