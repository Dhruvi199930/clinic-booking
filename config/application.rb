require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module ClinicBooking
  class Application < Rails::Application
    config.load_defaults 8.0

    config.time_zone = "Pacific Time (US & Canada)"
  end
end
