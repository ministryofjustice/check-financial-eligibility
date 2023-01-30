module ExceptionNotifier
  class TemplatedNotifier
    def initialize(_); end

    def call(exception, options = {})
      ExceptionAlertMailer.notify(
        error_message: exception.message,
        error_backtrace: exception.backtrace&.join("\n") || "Not available",
        error_options: options.to_s,
      ).deliver_now!
    end
  end
end
