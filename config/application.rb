require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "active_job/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module ClinicBooking
  class Application < Rails::Application
    config.load_defaults 8.0

    # Fallback only. Staff see times in their own zone, see ApplicationController.
    config.time_zone = "Pacific Time (US & Canada)"

    # The overlap trigger lives in SQL, which schema.rb can't represent.
    config.active_record.schema_format = :sql
  end
end
