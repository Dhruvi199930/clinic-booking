Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = ENV["CI"].present?
  config.consider_all_requests_local = true

  config.action_dispatch.show_exceptions = :rescuable
  config.cache_store = :null_store
  config.action_controller.allow_forgery_protection = false

  config.active_support.deprecation = :stderr

  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: "www.example.com" }
end
