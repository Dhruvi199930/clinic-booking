Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.action_view.annotate_rendered_view_with_filenames = true

  # Emails are written to tmp/mails instead of being sent.
  config.action_mailer.delivery_method = :file
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
end
