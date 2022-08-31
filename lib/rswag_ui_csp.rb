# Allows content served by Rswag::Ui
# to reference other sites or execute
# JS as necessary.
#
# see https://github.com/rswag/rswag/issues/174
#
# :nocov:
module Rswag::Ui::Csp
  def call(env)
    _, headers, = response = super
    headers["Content-Security-Policy"] = <<~POLICY.tr "\n", " "
      default-src 'self';
      img-src 'self' data: https://online.swagger.io https://validator.swagger.io/;
      font-src 'self' https://fonts.gstatic.com;
      style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
      script-src 'self' 'unsafe-inline';
    POLICY
    response
  end
end
# :nocov:

Rswag::Ui::Middleware.prepend Rswag::Ui::Csp
