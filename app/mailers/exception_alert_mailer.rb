class ExceptionAlertMailer < GovukNotifyRails::Mailer
  def notify(error_message:, error_backtrace:, error_options:)
    set_template(ENV["NOTIFICATIONS_ERROR_MESSAGE_TEMPLATE_ID"])
    set_personalisation(error_message:, error_backtrace:, error_options:)
    mail to: ENV["NOTIFICATIONS_RECIPIENT"].split(",")
  end
end
