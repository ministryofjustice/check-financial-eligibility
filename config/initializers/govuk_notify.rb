ActionMailer::Base.add_delivery_method(
  :govuk_notify,
  GovukNotifyRails::Delivery,
  api_key: ENV["NOTIFICATIONS_API_KEY"],
)
