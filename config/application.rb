require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Justask
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.autoload_paths += %W["#{config.root}/app/validators" "#{config.root}/app/api/*"]
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')


    # Use Sidekiq for background jobs
    config.active_job.queue_adapter = :sidekiq

    # DEPRECATION WARNING: Currently, Active Record suppresses errors raised
    # within `after_rollback`/`after_commit` callbacks and only print them to the logs.
    # In the next version, these errors will no longer be suppressed.
    # Instead, the errors will propagate normally just like in other Active Record callbacks.
    # fix for this warning:
    config.active_record.raise_in_transactional_callbacks = true

    config.after_initialize do
      Doorkeeper::Application.send :include, Concerns::ApplicationExtension

      ::APP_FAKE_OAUTH = Doorkeeper::Application.new(name: "Web", description: "#{APP_CONFIG["site_name"]} on the internets", homepage: "http#{APP_CONFIG["https"] && "s" || ""}://#{APP_CONFIG["hostname"]}#{APP_CONFIG["port"] && APP_CONFIG["port"] != 80 && ":#{APP_CONFIG["port"]}" || ""}", deleted: false, scopes: "-1")
      ::APP_FAKE_OAUTH.readonly!
    end
  end
end
