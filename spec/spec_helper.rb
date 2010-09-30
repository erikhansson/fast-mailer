# Setup bundler.
require 'bundler'
Bundler.setup

# Add lib to path and load emailer.
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'fast-mailer'
FastMailer.test_mode = true

# Load everything in spec/support.
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each do |s|
  require s
end
